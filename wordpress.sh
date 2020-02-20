##########################################
yum install vim -y  &> /dev/null
echo "Proceed to install Wordpress..?"
read ans

if [ $ans == "y" ]
then
echo "following components will be installed"
echo "1. Apache(httpd)"
echo "2. MariaDB(Mysql)"
echo "3. php"
echo "install size approximately 100mb"
else
echo "Operation Aborted"
fi
echo "press y to continue"
read op

if [ $op=="y" ]
then
touch log.txt
yum install wget -y  &> /dev/null
################################################
# installing httpd
echo "Installing httpd on the system please wait.........."
inst1=`yum list installed | grep httpd | wc -l`
if [ $inst1 -eq '0' ]
then
yum install httpd -y  &> /dev/null
echo "httpd=1" >> log.txt
systemctl restart httpd &> /dev/null
systemctl enable httpd &> /dev/null
echo "server installed and started"
else
echo "httpd already present"
fi
###############################################
# installing mariadb
echo "Installing mariadb on the system please wait.........."
inst2=`yum list installed | grep mariadb | wc -l`
if [ $inst2 -gt '0' ]
then
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
echo "mariadb installed and started"
else
echo "mariadb already present"
fi

#####################################################
#installing php7
echo "Installing php7 on the system please wait.........."
yum install yum-utils -y  &> /dev/null
yum -y install epel-release  &> /dev/null
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y  &> /dev/null
inst3=`yum list installed | grep php | wc -l`
if [ $inst3 -eq '0' ]
then
yum --enablerepo=remi-php72 install php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt -y  &> /dev/null
echo "php=1" >> log.txt 
else
echo "php already present"
fi

######################################################
#installing wordpress
echo "Installing Wordpress on the system please wait..........."
dir=/var/www/html/wp-config.php
if [ -f "$dir" ]
then
echo "wp=1" >> log.txt
else
wget http://wordpress.org/latest.tar.gz &> /dev/null
tar xzvf latest.tar.gz  &> /dev/null
yum install rsync -y &> /dev/null
rsync -avP ~/wordpress/* /var/www/html/  &> /dev/null
mkdir /var/www/html/wp-content/uploads -p
chown -R apache:apache /var/www/html/*
cd /var/www/html
cp wp-config-sample.php wp-config.php
yum install sed -y  &> /dev/null
sed -i 's/database_name_here/wordpressdb/i' wp-config.php
sed -i 's/username_here/wordpressdbadmin/i' wp-config.php
sed -i 's/password_here/getstartedhub/i' wp-config.php
sed -i 's/enforcing/disabled/i' /etc/selinux/config
fi


systemctl restart httpd
systemctl enable httpd
systemctl status httpd
systemctl restart mariadb
systemctl enable mariadb
systemctl status mariadb
systemctl stop firewalld

echo "copy your ip and paste it in the browser to go ahead with the installation"
else
echo "Operation Aborted"
fi
