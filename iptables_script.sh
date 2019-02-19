#!/bin/sh
passwd root
sed -i '/#PermitRootLogin yes/c\PermitRootLogin no' /etc/ssh/sshd_config
service sshd restart
##I commented the below command out temporarly incase I needed to get back into root.
#usermod -s /sbin/nologin root
iptables -F
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit 2/secon --limit-burst 2 -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s 172.20.240.20 --dport 3306 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3306 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP
service iptables save
service iptables restart
read -p 'New Username: ' newUser
useradd $newUser
passwd $newUser
usermod -aG wheel $newUser
#yum groupinstall -y 'X Window System'
#yum groupinstall -y 'Desktop'
#sed -i '/id:3:initdefault:/c\id:5:initdefault:' /etc/inittab
#yum groupinstall -y fonts
#startx
#usermod -s /bin/false sysadmin
#usermod -L sysadmin
cd .. && wget https://tinyurl.com/ydyujwnb && tar -xvzf ydyujwnb
cd rkhunter-1.4.6 && ./installer.sh --install && cd ..
wget https://tinyurl.com/y8wbpkcl && tar -xvzf y8wbpkcl
cd maldetect-1.6.3 && ./install.sh
cd .. && wget https://tinyurl.com/y7yy5p9h --no-check-certificate && tar -xvzf y7yy5p9h
cd lynis && chown -R root:root *

exit 0;
