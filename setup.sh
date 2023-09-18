#!/bin/bash
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Cập nhập OS
sudo apt update && sudo apt upgrade -y
sudo apt install zip -y
sudo apt install unzip -y
sudo apt install htop -y
sudo apt install screen -y

# Tạo 8GB Ram ảo
sudo fallocate -l 8G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile && echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Tắt firewall Oracle Ubuntu
sudo apt remove iptables-persistent -y
sudo ufw disable
sudo iptables -F

# Cài đặt Webinoly Reverse Proxy
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/webinoly/master/weby -O weby && sudo chmod +x weby && sudo ./weby -clean
sudo rm /opt/webinoly/webinoly.conf
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/Webinoly-Reverse-Proxy/main/reverse-proxy.conf -O /opt/webinoly/webinoly.conf
sudo stack -nginx -build=light

# Cài đặt Reverse Proxy cho img.bibica.net
sudo site img.bibica.net -proxy=[https://i0.wp.com/bibica.net/wp-content/uploads/] -dedicated-reverse-proxy=simple

# Bật FastCgi Cache
sudo site img.bibica.net -cache=custom

# Download key + pem cho SSL
mkdir -p /root/ssl
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/bibica.net/main/bibica.net.pem -O /root/ssl/bibica.net.pem
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/bibica.net/main/bibica.net.key -O /root/ssl/bibica.net.key
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/bibica.net/main/bibica.net.crt -O /root/ssl/bibica.net.crt

# Setup SSL cho img.bibica.net
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/Webinoly-Reverse-Proxy/main/img.bibica.net -O /etc/nginx/sites-available/img.bibica.net

# Chỉnh lại cấu hình FastCgi Cache
mkdir -p /var/www/img_bibica_net
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/Webinoly-Reverse-Proxy/main/img.bibica.net-proxy.conf -O /etc/nginx/apps.d/img.bibica.net-proxy.conf
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/Webinoly-Reverse-Proxy/main/fastcgi.conf -O /etc/nginx/conf.d/fastcgi.conf
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/Webinoly-Reverse-Proxy/main/webinoly.conf -O /etc/nginx/conf.d/webinoly.conf

# Nginx reload
nginx -t
sudo service nginx reload

# Bypass Oracle VM.Standard.E2.1.Micro
sudo wget --no-check-certificate https://raw.githubusercontent.com/bibicadotnet/NeverIdle-Oracle/master/VM.Standard.E2.1.Micro.sh -O /usr/local/bin/bypass_oracle.sh
chmod +x /usr/local/bin/bypass_oracle.sh
nohup /usr/local/bin/bypass_oracle.sh >> ./out 2>&1 <&- &
crontab -l > bypass_oracle
echo "@reboot nohup /usr/local/bin/bypass_oracle.sh >> ./out 2>&1 <&- &" >> bypass_oracle
crontab bypass_oracle

# Kiểm tra lại Webinoly
sudo webinoly -verify
sudo webinoly -info
