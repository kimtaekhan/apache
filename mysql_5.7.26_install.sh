#!/bin/sh

#** MAKE BY KIM TAEK HAN
#*  2019.05.11

# echo color
font_bold="\e[1m"
font_blink="\e[5m"
font_red="\033[2;31m"
font_green="\033[2;32m"
font_yellow="\033[2;33m"
font_blue="\033[2;34m"
font_purple="\033[2;35m"
font_aqua="\033[2;36m"
font_white="\033[2;37m"
font_reset="\033[1;0m"

# default path
default_path="/usr/local/src"

# default mysql path
mysql_path="/usr/local/src/apm/mysql"

# clear output
clear

# start installation
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
                                     start mysql installtion !
\033[1;0m
"
for i in `seq 5 -1 0`;
do
	echo -en "\r\t\t\t\t\t\t${i}"
	sleep 1
done

echo

# default installation directory
cd ${mysql_path}

# Installing mysql-5.7.26.tar.gz for compilation installation
# Installing libraries for compilation installation

# download  mysql file
wget "https://github.com/kimtaekhan/apm_big/raw/master/mysql-5.7.26.tar.gz"

# download boost file
wget "https://github.com/kimtaekhan/apm_big/raw/master/boost_1_59_0.tar.gz"

# download cmake file
wget "https://github.com/kimtaekhan/apm/raw/master/cmake-3.0.2.tar.gz"

# file size 52M
tar xvfz mysql-5.7.26.tar.gz
# file size 80M
tar xvfz boost_1_59_0.tar.gz
# file size 5.3M
tar xf cmake-3.0.2.tar.gz

# Check the number of cores in use on this system
system_core_count=`grep -c processor /proc/cpuinfo`

# Installing package for compilation installation
yum -y groupinstall "Development tools"
yum -y install ncurses ncurses-devel
cd ${mysql_path}/cmake-3.0.2
./bootstrap

# make (cmake)
make -j $system_core_count

# make install (cmake)
make install

check_done_cmake=`cmake -version | wc -l`

if [ ${check_done} -ne 0 ]
then
	echo -en "${font_aqua}cmake install ${font_white}[   ${font_green}OK   ${font_white}]${font_reset}\n"
fi

cd ${mysql_path}/mysql-5.7.26

# cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DWITH_EXTRA_CHARSETS=all -DMYSQL_DATADIR=/usr/local/mysql/data -DENABLED_LOCAL_INFILE=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../boost_1_59_0 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DSYSCONFDIR=/etc -DDEFAULT_CHARSET=euckr -DDEFAULT_COLLATION=euckr_korean_ci -DWITH_EXTRA_CHARSETS=all

# make (mysql)
make -j $system_core_count

# make install (mysql)
make install

# Set up executable files to run regardless of path
ln -sf /usr/local/mysql/bin/* /usr/bin

# Copy daemon script permission 700
install -m 700 /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld

# add chkconfig list for mysqld daemon script
chkconfig --add mysqld

# create mysql user
useradd -s /bin/false -d /usr/local/mysql/data -M -r -u 27 mysql

# Database reset
/usr/local/mysql/bin/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data 

# change /usr/local/mysql/data directory permission
chown -R mysql.mysql /usr/local/mysql/data

# create mysql config file
\cp -f /usr/local/mysql/mysql-test/include/default_my.cnf /etc/my.cnf

# start mysql daemon
/etc/init.d/mysqld start

# variable mysql password
mysql_pass=`tail -n 1 /root/.mysql_secret`

# mysql root password reset
mysql -uroot -p$mysql_pass mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '';" --connect-expired-password

# done !
