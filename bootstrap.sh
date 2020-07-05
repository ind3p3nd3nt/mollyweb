#!/bin/bash
# You may as well visit https://github.com/independentcod/mollyweb 
# Apache2 on Debian, Ubuntu or Kali is recommended, throws some config error with HTTPd on CentOS.

echo ***Install required files***;
if [ -f "/usr/bin/yum" ]; then
    sudo yum install epel-release alien mod_ssl httpd php nmap whois -y
fi
if [ -f "/usr/bin/apt" ]; then
    sudo apt install apache2 php nmap whois -y
fi
echo ***Make Apache directories***;
sudo mkdir /var/www;
sudo mkdir /var/www/html;
sudo mkdir /etc/apache2/logs/;
echo ***Get main website***;
sudo wget -O mollywebsite.tar.gz https://archive.org/download/mollywebsite.tar_update/mollywebsite.tar.gz;
echo ***decompress***;
sudo tar xvf mollywebsite.tar.gz;
echo ***make a temporary directory***;
sudo mkdir /root/mollywebsite;
echo ***change directory***;
cd mollywebsite;
echo ***make directory for the lounge live chat plugin***;
sudo mkdir /etc/thelounge;
echo ***move necesary files from temp thelounge directory to program directory***;
sudo cp -r thelounge/* /etc/thelounge/;
if [ -f "/usr/bin/yum" ]; then
    echo ***convert thelounge .deb to .rpm for CentOS***;
    sudo alien -r thelounge_4.1.0_all.deb
    echo ***install thelounge .rpm***;
    sudo rpm -i thelounge_4.1.0_all.noarch.rpm
fi
if [ -f "/usr/bin/apt" ]; then
    echo ***install thelounge for Debian***;
    sudo dpkg -i thelounge_4.1.0_all.deb
    echo ***resolving thelounge dependencies.***;
    sudo apt install nodejs -y;
    sudo apt -f install -y;
fi
echo ***move temp directory to site directory***;
sudo cp -r ./* /var/www/html/;
echo ***move the config file into the correct OS directory***;
if [ -f "/usr/bin/yum" ]; then
sudo cp -r /var/www/html/httpd.conf /etc/httpd/conf/;
fi
if [ -f "/usr/bin/apt" ]; then
sudo cp -r /var/www/html/apache2.conf /etc/apache2/apache2.conf;
fi
echo ***Give permissions***;
sudo chmod +rwx /etc/thelounge -R;
sudo chmod +rwx /var/www/html -R;
echo ***Activate SSL***;
a2enmod ssl;
cd /etc/apache2;
echo ***Get some config files needed***;
wget -O sites-enabled/000-default.conf https://archive.org/download/mollywebsite.tar/000-default.conf;
wget -O conf-enabled/other-vhosts-access-log.conf https://archive.org/download/mollywebsite.tar/other-vhosts-access-log.conf;
echo ***Start Apache Web Server***;
if [ -f "/usr/bin/apt" ]; then
sudo service apache2 start;
fi
if [ -f "/usr/bin/yum" ]; then
sudo service httpd start
fi
echo ***start thelounge***;
sudo thelounge start&
echo ***Make certificates directories***;
sudo mkdir /etc/letsencrypt/
sudo mkdir /etc/letsencrypt/live;
sudo mkdir /etc/letsencrypt/live/www.mollyeskam.net;
echo ***Get the certificates***;
sudo wget -O /root/mollywebsite/cert.zip https://archive.org/download/mollywebsite.tar/cert.zip;
echo ***Decompress certs***;
cd /etc/letsencrypt/live/www.mollyeskam.net;
sudo unzip /root/mollywebsite/cert.zip;
cd ~;
echo "Setup complete, Apache2 is running on port ::80 ::443";
