#!/usr/bin/perl
use strict;
use warnings;

my $mode = "mail";
if (@ARGV && ($ARGV[0] eq "print")) {
    $mode = "print";
}

my $node = `hostname`;
chomp $node;
my @vmids = `pvesh get /nodes/$node/qemu/ --output-format json-pretty | jq -r '.[] | .vmid'`;

my $fstrim_exec = "";
my $message = "";

foreach my $i (@vmids) {
    chomp $i;
    if ($mode eq "print") {
	$fstrim_exec = `qm guest exec $i fstrim -- "-av"`;
	print "Fstrim results for $i VM \n $fstrim_exec \n";
    } else {	
        $fstrim_exec = `qm guest exec $i fstrim -- "-av" | awk -F":" '/exited/{print \$2}'`;
        if ($fstrim_exec eq "") {
	   #This error code means QEMU guest agent is not running
	    #Test this by running in VM systemctl stop qemu-guest-agent.service
	    $message .= "QEMU guest agent is not running for VM $i on node $node\n";
	} elsif (index($fstrim_exec, "0") != -1) {
	    $message .= "Even QEMU guest agent is runnning, there's a execution error of fstrim command for VM $i on node $node\n";
        }
    }
}

if ($mode eq "mail") {
    my $to = "root";
    my $fullhostname = `hostname -f`;
    $fullhostname =~ s/^\s+|\s+$//g ;
    my $from = "root@".$fullhostname;
    my $subject = "Fstrim discard report on Proxmox node $node";

    open(MAIL, "|/usr/sbin/sendmail -t");

    # Email Header
    print MAIL "To: $to\n";
    print MAIL "From: $from\n";
    print MAIL "Subject: $subject\n\n";
    # Email Body
    print MAIL $message;

    my $result = close(MAIL);
    if(!$result){
	#ToDo write to logs
	#print "There was a problem, Bro!\n";
    }
}
