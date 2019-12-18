#!/bin/sh
iptables -F
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
##iptables -A INPUT -s 10.0.0.0/8 -j DROP 
##iptables -A INPUT -s 169.254.0.0/16 -j DROP
##iptables -A INPUT -s 172.16.0.0/12 -j DROP
iptables -A INPUT -s 127.0.0.0/8 -j DROP
##iptables -A INPUT -s 192.168.0.0/24 -j DROP
iptables -A INPUT -s 224.0.0.0/4 -j DROP
iptables -A INPUT -d 224.0.0.0/4 -j DROP
iptables -A INPUT -s 240.0.0.0/5 -j DROP
iptables -A INPUT -d 240.0.0.0/5 -j DROP
iptables -A INPUT -s 0.0.0.0/8 -j DROP
iptables -A INPUT -d 0.0.0.0/8 -j DROP
iptables -A INPUT -d 239.255.255.0/24 -j DROP
iptables -A INPUT -d 255.255.255.255 -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j LOG --log-prefix "Address-Mask Drop: " --log-level 4
iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j LOG --log-prefix "Timestamp Drop: " --log-level 4
iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -p icmp -m icmp -m limit --limit 1/second -j ACCEPT
iptables -A INPUT -m state --state INVALID -j LOG --log-prefix "Invalid Drop: " --log-level 4
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j LOG --log-prefix "Forward Invalid Drop: " --log-level 4
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j LOG --log-prefix "OUTPUT Invalid Drop: " --log-level 4
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:" --log-level 4
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:" --log-level 4
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
iptables -A INPUT -p tcp -m tcp --dport 22 -m recent --name sshattempt --set -j REJECT --reject-with tcp-reset
iptables -A INPUT -m recent --name sshattempt --rcheck --seconds 86400 -j DROP
iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A INPUT -m recent --name portscan --remove
iptables -A FORWARD -m recent --name portscan --remove
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
##iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j LOG --log-prefix "ICMP Attempt: " --log-level 4
iptables -A INPUT -p icmp --icmp-type echo-request -j REJECT
iptables -A INPUT -j REJECT
iptables -P OUTPUT -j ACCEPT
iptables -A FORWARD -j REJECT
service iptables save
service iptables restart
