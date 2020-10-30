#!/usr/bin/perl
use strict;
use warnings;

my $node = `hostname`;
chomp $node;
my @vmids = `pvesh get /nodes/$node/qemu/ --output-format json-pretty | jq -r '.[] | .vmid'`;

foreach my $i (@vmids) {
    chomp $i;
    my $fstrim_exec = "";
    #$fstrim_exec = `qm guest exec $i fstrim -- "-av"`;
    #print "Fstrim results for $i VM \n $fstrim_exec \n";
    $fstrim_exec = `qm guest exec $i fstrim -- "-av" | awk -F":" '/exited/{print \$2}'`;
    if ($fstrim_exec eq "") {
	#This error code means QEMU guest agent is not running
	#Test this by running in VM systemctl stop qemu-guest-agent.service
	print "No agent for $i\n";
    } elsif (index($fstrim_exec, "0") != -1) {
	print "Even QEMU guest agent is runnning, there's a execution error for $i VM";
    }
}

