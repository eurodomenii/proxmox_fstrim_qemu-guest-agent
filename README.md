For performance reasons, instead of mounting with discard option inside KVM, it's better running external fstrim command via qemu-guest-agent, on host cron event
However, discard=on must be setup in KVM storage configuration at /etc/pve/qemu-server/VMid.conf 

