#!/bin/sh

. /usr/local/src/apm/config/apm_config

yum -y remove pcre-devel
yum -y install zlib zlib-devel

# only centos5
# sed -i '19s/.*/ \/* Linuxthreads *\//g' /usr/include/pthread.h

# Apache 2.4.39 Install Start !
echo -en "
\033[3;36m
                            ._________     _  ___________  __________  ____           
                            |   |/  /     |__   __|       |   |__|  |                  
                            |   /  /        |\ /|         |   /__\  |                   
                            |   \  \        |/ \|         |   /__ \ |                   
                            | __|\__\       |\_/|         /__/|  |_\|                  
                            /\      \\/      //    \/        //      /\  \\/          
\033[1;0m\033[2;31m
                                        MAKE BY KIMTAEKHAN
\033[1;0m\033[1;33m\e[5m
                                     start apache installtion !
\033[1;0m
"
for i in `seq 5 -1 0`;
do
	echo -en "\r\t\t\t\t\t\t${i}"
	sleep 1
done

# wget
. ${apache_path}/2.4_download

# tar & mv
tar xzf httpd-2.4.39.tar.gz
tar xzf openssl-1.0.1i.tar.gz
tar xjf pcre-8.35.tar.bz2
tar xzf apr-1.5.1.tar.gz
tar xzf apr-util-1.5.3.tar.gz

# install openssl-1.0.1i
cd ${apache_path}/openssl-1.0.1i
./config \ --prefix=/usr/local/openssl \ --openssldir=/usr/local/openssl \ threads  zlib  shared
make && make install 
echo /usr/local/openssl/lib >> /etc/ld.so.conf
ldconfig

# install pcre-8.35
cd ${apache_path}/pcre-8.35
./configure
make && make install

# install apr-1.5.1
cd ${apache_path}/apr-1.5.1
./configure
make && make install
echo /usr/local/apr/lib >> /etc/ld.so.conf
ldconfig

# install apr-util-1.5.3
cd ${apache_path}/apr-util-1.5.3
./configure --with-apr=/usr/local/apr
make && make install
ldconfig


# apache configure
cd ${apache_path}/httpd-2.4.39
./configure --prefix=/usr/local/apache --enable-mods-shared=all --enable-module=so --with-mpm=prefork --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr --enable-module=ssl --with-ssl=/usr/local/openssl --enable-ssl
make && make install

# symlink
ln -s /usr/local/apache/bin/* /usr/bin
ln -s /usr/local/apache/bin/apachectl /etc/init.d/httpd
sed -i '1a# chkconfig: 2345 65 35' /etc/init.d/httpd
sed -i '2a# description: apache web server' /etc/init.d/httpd

# chkconfig
chkconfig --add httpd
chkconfig --list httpd

# Domain Error Off
err_off_number=`cat -n /usr/local/apache/conf/httpd.conf | grep "www.example.com:80" | awk '{print $1}'`
sed -i ''"${err_off_number}"'d' /usr/local/apache/conf/httpd.conf
sed -i ''"${err_off_number}"'i ServerName www.example.com:80' /usr/local/apache/conf/httpd.conf

# httpd service start
/etc/init.d/httpd start

# test page work
cat << index > /usr/local/apache/htdocs/index.html
<html>
	<head>
		<!--
			title
		-->
		<title> install OK ! </title>

		<!--
			style
		-->
		<style>
			* {
			    margin: 0px;
    			padding: 0px;
			}
			html, body
			{
				text-align: center;
    			height: 100%;
			}
			#kth
			{
				font-size: 30;
				font-weight: bold;
				margin: 20px;
				text-align: center;
			}
		</style>
	</head>
	<body>
		<font size=10>Thanks for using KTH apm installation script !</font><br><br>
		<br><br><br><br>
		<br><br><br><br>
		<img src="https://github.com/kimtaekhan/done_img/raw/master/apache.jpg" width="500" height="250" alt="apache" />
		<img src="https://github.com/kimtaekhan/done_img/raw/master/php.jpg" width="500" height="250" alt="apache" />
		<img src="https://github.com/kimtaekhan/done_img/raw/master/mysql.png" width="500" height="250" alt="apache" />
		<div id="kth">
			<br><br><br><br>
			<br><br>Copyright &#169; KIM TAEK HAN<br>
		</div>
	</body>
</html>
index


# accept 80 port
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
