#!/usr/bin/perl
use strict;
use warnings;

my $node = `hostname`;
chomp $node;
my @vmids = `pvesh get /nodes/$node/qemu/ --output-format json-pretty | jq -r '.[] | .vmid'`;

foreach my $i (@vmids) {
    chomp $i;
    my $fstrim_exec = "";
    my $mail = "";
    system '/usr/bin/mail -s "subject to root" root <<< "message"';

    $fstrim_exec = `qm guest exec $i fstrim -- "-av" | awk -F":" '/exited/{print \$2}'`;
    if ($fstrim_exec eq "") {
	#This error code means QEMU guest agent is not running
	#Test this by running in VM systemctl stop qemu-guest-agent.service
	$mail = `mail -s "No agent for VM $i on node $node" root <<< "QEMU guest agent is not running for VM $i\n"`;
    } elsif (index($fstrim_exec, "0") != -1) {
	$mail =`mail -s "Fstrim agent execution error on for VM $i on node $node" root <<< "Even QEMU guest agent is runnning, there's a execution error for VM $i"`;
    }
}

