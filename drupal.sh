#Maintainer: Indrajeet Sohoni
echo "Proceed to install Drupal..?"
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
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

echo "installing httpd"
yum install httpd -y
systemctl restart httpd
systemctl enable httpd
FILE=/var/www/html
if test -d "$FILE"
then
echo "apache=1" >> log.txt
fi
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

echo "installing php"
yum install php55w php55w-opcache php55w-mbstring php55w-gd php55w-xml php55w-pear php55w-fpm php55w-mysql -y
FILE=/bin/php
if test -f "$FILE"
then
echo "php=1" >> log.txt
fi

yum install mariadb-server mariadb -y
systemctl restart mariadb
systemctl enable mariadb
mysql_secure_installation <<EOF
y
secret
secret
y
y
y
y
EOF
mysql -u root -pgetstartedhub -e "create database drupal_db;"
mysql -u root -pgetstartedhub -e "create user drupaladmin@localhost IDENTIFIED BY 'getstartedhub';"
mysql -u root -pgetstartedhub -e "GRANT ALL PRIVILEGES ON drupal_db.* TO drupaladmin@localhost;"
mysql -u root -pgetstartedhub -e "FLUSH PRIVILEGES;"
mysql -u root -pgetstartedhub -e "exit"
systemctl restart mariadb
FILE=/etc/my.cnf
if test -f "$FILE"
then
echo "mariadb=1" >> log.txt
fi

echo "installing gzip"
yum install wget gzip -y
FILE=/bin/gzip
if test -f "$FILE"
then
echo "gzip=1" >> log.txt
fi

wget https://ftp.drupal.org/files/projects/drupal-8.0.2.tar.gz
tar -zxpvf drupal-8.0.2.tar.gz
mv drupal-8.0.2/* /var/www/html/
chown -R apache:apache /var/www/html/
cd /var/www/html/sites/default/
cp -p default.settings.php settings.php
chcon -R -t httpd_sys_content_rw_t /var/www/html/
systemctl stop firewalld
echo "copy your ip and paste it in the browser to go ahead with the installation"
else
echo "Operation Aborted"
fi
