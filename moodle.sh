#Maintainer: Indrajeet Sohoni
echo "Proceed to install Moodle..?"
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

# installing httpd
echo "Installing httpd on the system please wait.:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:."
yum install httpd -y
systemctl restart httpd
systemctl enable httpd
systemctl status httpd

# installing mariadb
echo "Installing mariadb on the system please wait.:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:."
yum group install mariadb mariadb-client -y
systemctl restart mariadb
systemctl enable mariadb
systemctl status mariadb
mysql_secure_installation
mysql -u root -pgetstarted -e "create database moodle;"
mysql -u root -pgetstarted -e "create user moodleuser@localhost IDENTIFIED BY 'getstarted'"
mysql -u root -pgetstarted -e "GRANT ALL PRIVILEGES ON moodle.* TO moodleuser@localhost IDENTIFIED BY 'getstarted';"
mysql -u root -pgetstarted -e "flush privileges"

# Installing PhP7
echo "Installing php7 on the system please wait.:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:."
yum install yum-utils -y
yum install epel-release -y
yum-config-manager --disable remi-php54
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager ––enable remi–php73
yum install php mod_php73w php73w-common php73w-mbstring php73w-xmlrpc php73w-soap php73w-gd php73w-xml php73w-intl php73w-mysqlnd php73w-cli php73w-mcrypt php73w-ldap -y
php –v

# installing Moodle
echo "Installing Moodle on the system please wait.:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:.:.:.:.:.:..:.:."
wget https://download.moodle.org/download.php/direct/stable31/moodle-latest-31.tgz
tar -xzvf moodle-latest-31.tgz
yum install rsync -y
rsync -avP ~/moodle/* /var/www/html/
mv /root/moodle/* /var/www/html/
#mkdir /var/www/html/wp-content/uploads -p
chown -R apache:apache /var/www/html/*
chmod -R 755 /var/www/html
mkdir /var/www/moodledata
chown -R apache:apache /var/www/moodledata
chmod -R 755 /var/www/moodledata
systemctl restart httpd
cp /var/www/html/config-dist.php /var/www/html/config.php
cd /var/www/html
yum install sed -y
sed -i 's/example.com/localhost/g' /var/www/html/config.php
original="/home/example"
final="/var/www/moodledata"
sed -i 's/original/final/i' /var/www/html/config.php

#sed 's/CFG->wwwroot   = 'http://your-domain.com'/CFG->wwwroot   = 'http://localhost'/g' config.php
#sed 's/username_here/wordpressdemo/i' config.php
#sed 's/password_here/gshub/i' config.php

systemctl restart httpd
systemctl enable httpd
systemctl status httpd

systemctl restart mariadb
systemctl enable mariadb
systemctl status mariadb

systemctl restart mariadb
systemctl enable mariadb
systemctl status mariadb
systemctl stop firewalld

echo "copy your ip and paste it in the browser to go ahead with the installation"
else
echo "Operation Aborted"
fi
