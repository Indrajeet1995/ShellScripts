##################################
echo " Please wait while the script completes execution to avoid any errors"
date >> log.txt
yum install vim -y &> /dev/null
echo " Proceed to install Drupal...[y/n]"
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
firewall-cmd --permanent --zone=public --add-service=http &> /dev/null
firewall-cmd --permanent --zone=public --add-service=https &> /dev/null
firewall-cmd --reload &> /dev/null

#################################
#installing php

echo " Installing php7 on the system please wait.........."
yum install yum-utils -y  &> /dev/null
yum -y install epel-release  &> /dev/null
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y  &> /dev/null
inst3=`yum list installed | grep php | wc -l`
if [ $inst3 -eq '0' ]
then
yum --enablerepo=remi-php72 install php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt -y  &> /dev/null
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
mysql -u root -pgetstartedhub -e "create database wordpressdb;"  &> /dev/null
mysql -u root -pgetstartedhub -e "create user wordpressdbadmin@localhost IDENTIFIED BY 'getstartedhub';"  &> /dev/null
mysql -u root -pgetstartedhub -e "GRANT ALL PRIVILEGES ON wordpressdb.* TO wordpressdbadmin@localhost IDENTIFIED BY 'getstartedhub';"  &> /dev/null
mysql -u root -pgetstartedhub -e "flush privileges;"  &> /dev/null
echo " mariadb installed and started"
fi

##############################
#installing gzip
#echo "installing gzip"
#inst3=`yum list installed | grep gzip | wc -l`
#if [ $inst3 -gt '1' ]
#then
#echo "gzip alrady present"
#else
#yum install gzip -y
#echo "gzip=1" >> log.txt
#echo "gzip installed and started"
#fi


#############################
#installing Drupal


echo " Installing Drupal on the system please wait..........."
dir=/var/www/html/web.config
if [ -f "$dir" ]
then
echo " Drupal Files already present"
else
wget https://ftp.drupal.org/files/projects/drupal-8.0.2.tar.gz  &> /dev/null
tar -zxpvf drupal-8.0.2.tar.gz  &> /dev/null
mv drupal-8.0.2/* /var/www/html/
chown -R apache:apache /var/www/html/
cd /var/www/html/sites/default/
cp -p default.settings.php settings.php
chcon -R -t httpd_sys_content_rw_t /var/www/html/  &> /dev/null
fi

systemctl restart httpd
systemctl enable httpd
systemctl status httpd >> log.txt
systemctl restart mariadb
systemctl enable mariadb
systemctl status mariadb >> log.txt
systemctl stop firewalld

echo " copy your ip and paste it in the browser to go ahead with the installation"
else
echo " Operation Aborted"
fi
