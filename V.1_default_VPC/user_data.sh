#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
sudo yum install -y mysql
sudo amazon-linux-extras enable php7.4
sudo yum clean metadata
sudo yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap,devel}

sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;
#echo "<?php phpinfo(); ?>" > /var/www/html/index.php

# myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

# cat <<EOF > /var/www/html/index.html
# <html>
# <body bgcolor="silver">
# <font color="#333">Server PrivateIP: <font color="#333">$myip<br>
# </body>
# </html>
# EOF

sudo mkdir -p /var/www/inc

sudo cat <<EOF > /var/www/inc/dbinfo.inc
<?php

define('DB_SERVER', '${rds_endpoint}');
define('DB_USERNAME', 'webapp');
define('DB_PASSWORD', '${aaaaaaaaa}');
define('DB_DATABASE', 'appmariadb');

?>
EOF

cd /var/www/html
wget https://raw.githubusercontent.com/gagasgit/DATABASE_Check_APP/main/index.php


sudo service httpd start
chkconfig httpd on
