For performance reasons, instead of mounting with discard option inside KVM, it's better running external fstrim command via qemu-guest-agent, on host cron event.

However, discard=on must be setup in KVM storage configuration at /etc/pve/qemu-server/VMid.conf 

Default mode is sending mail to Linux root when QEMU guest agent is running, or on another execution error
> cat /etc/crontab

> */30 *  * * *   root   /var/eurodomenii/scripts/github/proxmox_fstrim_qemu-guest-agent/fstrim_via_guest-agent.pl >/dev/null 2>&1


Howewer, there's a print mode on screen:  

> ./fstrim_via_guest-agent.pl print


