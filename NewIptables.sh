#!/bin/sh
iptables -F
# Log attack
iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> Null scan "
# Drop and blacklist for 60 seconds IP of attacker
iptables -A INPUT -p tcp --tcp-flags ALL NONE  -m recent --name blacklist_60 --set -j REJECT --reject-with tcp-reset
# Log attacks
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS scan "
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS-PSH scan "
iptables -A INPUT -p tcp --tcp-flags ALL ALL -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> XMAS-ALL scan "
# Drop and blacklist for 60 seconds IP of attacker
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m recent --name blacklist_60 --set -j REJECT --reject-with tcp-reset# Xmas-PSH scan
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -m recent --name blacklist_60 --set -j REJECT --reject-with tcp-reset # Against nmap -sX (Xmas tree scan)
iptables -A INPUT -p tcp --tcp-flags ALL ALL -m recent --name blacklist_60 --set -j REJECT --reject-with tcp-reset# Xmas All scan
#Log attack
iptables -A INPUT -p tcp --tcp-flags ALL FIN -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> FIN scan "
# Drop and blacklist for 60 seconds IP of attacker
iptables -A INPUT -p tcp --tcp-flags ALL FIN -m recent --name blacklist_60 --set -j REJECT --reject-with tcp-reset
iptables   -A INPUT -p tcp ! --syn -m state --state NEW -j REJECT --reject-with tcp-reset
# log  probable sS and full connect tcp scan
iptables -A INPUT -p tcp  -m multiport --dports 23,79 --tcp-flags ALL SYN -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall>SYN scan trap:" 
# blacklist for three minuts
iptables -A  INPUT -p tcp  -m multiport --dports 23,79 --tcp-flags ALL SYN -m recent --name blacklist_180 --set -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp  -m limit --limit 6/h --limit-burst 1 -m length --length 0:28 -j LOG --log-prefix "Firewall>0 length udp "
iptables -A INPUT -p udp -m length --length 0:28 -j REJECT --reject-with icmp-host-unreachable
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -P INPUT REJECT
iptables -P OUTPUT ACCEPT
service iptables save
service iptables restart
exit 0;
