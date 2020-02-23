 Please wait while the script completes execution to avoid any errors
 Proceed to install Joomla...[y/n]
y
 following components will be installed
 1. Apache(httpd)
 2. MariaDB(Mysql)
 3. php
 install size approximately 100mb...Proceed[n/y]
press y to continue
y
 Installing httpd on the system please wait..........
 server installed and started
 Installing php7 on the system please wait..........
 installed & Active
 Installing mariadb on the system please wait..........
 mariadb installed and started
installing joomla
 copy your ip and paste it in the browser to go ahead with the installation
[root@localhost ~]# sh joomla.sh
 Please wait while the script completes execution to avoid any errors
 Proceed to install Joomla...[y/n]
y
 following components will be installed
 1. Apache(httpd)
 2. MariaDB(Mysql)
 3. php
 install size approximately 100mb...Proceed[n/y]
press y to continue
y
 Installing httpd on the system please wait..........
 httpd already present
 Installing php7 on the system please wait..........
 php already present
 Installing mariadb on the system please wait..........
 mariadb already installed
installing joomla
 Joomla Files already present
 copy your ip and paste it in the browser to go ahead with the installation
[root@localhost ~]# cat joomla.sh
##################################
echo " Please wait while the script completes execution to avoid any errors"
date >> log.txt
yum install vim -y &> /dev/null
echo " Proceed to install Joomla...[y/n]"
read ans

if [ $ans == "y" ]
then
echo " following components will be installed"
echo " 1. Apache(httpd)"
echo " 2. MariaDB(Mysql)"
echo " 3. php"
echo " install size approximately 100mb...Proceed[n/y]"
else
echo "Operation Aborted"
fi
echo "press y to continue"
read op

if [ $op=="y" ]
then
touch log.txt
yum install wget -y &> /dev/null
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &> /dev/null
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm  &> /dev/null
##################################
#installing httpd

echo " Installing httpd on the system please wait.........."
inst1=`yum list installed | grep httpd | wc -l`
if [ $inst1 -eq '0' ]
then
yum install httpd -y  &> /dev/null
echo "httpd=1" >> log.txt
systemctl restart httpd &> /dev/null
systemctl enable httpd &> /dev/null
echo " server installed and started"
else
echo " httpd already present"
fi
#firewall-cmd --permanent --zone=public --add-service=http &> /dev/null
#firewall-cmd --permanent --zone=public --add-service=https &> /dev/null
#firewall-cmd --reload &> /dev/null

#################################
#installing php

echo " Installing php7 on the system please wait.........."
yum install yum-utils -y  &> /dev/null
yum -y install epel-release  &> /dev/null
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y  &> /dev/null
inst3=`yum list installed | grep php | wc -l`
if [ $inst3 -eq '0' ]
then
yum --enablerepo=remi-php72 install php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt php-curl php-pear php-memcache php-pspell php-snmp php-xmlrpc -y  &> /dev/null
echo "php=1" >> log.txt
echo " installed & Active"
else
echo " php already present"
fi

################################
#installing mariadb

echo " Installing mariadb on the system please wait.........."
inst2=`yum list installed | grep mariadb | wc -l`
if [ $inst2 -gt '1' ]
then
echo " mariadb already installed"
else
yum install -y mariadb-server mariadb-client  &> /dev/null
echo "mariadb=1" >> log.txt
systemctl restart mariadb &> /dev/null
systemctl enable mariadb  &> /dev/null
mysql_secure_installation   &> /dev/null <<EOF

y
getstartedhub
getstartedhub
y
y
y
y
EOF
mysql -u root -pgetstartedhub -e "create database joomladb;"  &> /dev/null
mysql -u root -pgetstartedhub -e "create user joomladbadmin@localhost IDENTIFIED BY 'getstartedhub';"  &> /dev/null
mysql -u root -pgetstartedhub -e "GRANT ALL PRIVILEGES ON joomladb.* TO joomladbadmin@localhost IDENTIFIED BY 'getstartedhub';"  &> /dev/null
mysql -u root -pgetstartedhub -e "flush privileges;"  &> /dev/null
echo " mariadb installed and started"
fi

################################
#installing Joomla

echo " installing joomla"
dir=/var/www/html/web.config.txt
if [ -f "$dir" ]
then
echo " Joomla Files already present"
else
wget https://downloads.joomla.org/cms/joomla3/3-9-15/Joomla_3-9-15-Stable-Full_Package.zip &> /dev/null
yum install unzip -y &> /dev/null
unzip -q Joomla_3-9-15-Stable-Full_Package.zip -d /var/www/html/
chown -R apache:apache /var/www/html/
chmod -R 775 /var/www/html/
sed -i 's/AllowOverride None/AllowOverride All/i' /etc/httpd/conf/httpd.conf
sed -i 's/enforcing/disabled/i' /etc/selinux/config
fi

systemctl restart httpd
systemctl enable httpd
systemctl status httpd >> log.txt
systemctl restart mariadb
systemctl enable mariadb
systemctl status mariadb >> log.txt
firewall-cmd --permanent --add-service=http &> /dev/null
firewall-cmd --permanent --add-service=https &> /dev/null
firewall-cmd  --reload &> /dev/null
systemctl stop firewalld
echo " copy your ip and paste it in the browser to go ahead with the installation"
else
echo " Operation Aborted"
fi
