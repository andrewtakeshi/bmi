# Icinga2/Icinga Web 2 Setup Guide
### By: Andrew Golightly

This guide was made assuming a clean install of CentOS 7. Instructions for other distros are available online; here are some of the better resources I was able to find. 

- [Official Icinga Installation Guide](https://icinga.com/docs/icinga2/latest/doc/02-installation/)
- [Debian/Ubuntu (Computing for Geeks)](https://computingforgeeks.com/how-to-install-icinga2-monitoring-tool-on-ubuntu-18-04-lts/)

For the purposes of CHPC monitoring, we chose (at this time) to do agentless monitoring via SNMP. As such, we don't make use of many key Icinga features, i.e. Icinga Agent/Icinga Director.

As an alternative, I've created a script which can be run using the following commands (requires root):
```
git clone https://github.com/andrewtakeshi/chpc ./chpc
cd chpc/icinga_config.d
chmod +x icingacombined_setup
./icingacombined_setup
```

If for whatever reason the script fails or you want to manually follow the steps, do the following (requires root/sudo access). 

1. Disable SELinux - with SELinux enabled, we are unable to run most CheckCommands. 
```
sed -i 's/^SELINUX=[[:alpha:]]\+$/SELINUX=disabled/' /etc/selinux/config
setenforce 0
```
2. Add the epel-release repository.
```
yum install epel-release
```
3. Add the Icinga2 Official Repository, install Icinga2, and install the latest Nagios plugins package.  
```
rpm --import https://packages.icinga.com/icinga.key
yum install https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm
yum install icinga2 nagios-plugins-all
```
4. Start Icinga2. 
```
systemctl enable icinga2 --now
```
5. Install and start mariaDB (MySQL).
```
yum install mariadb-server mariadb
systemctl enable mariadb --now
# Optional, but highly recommended
mysql_secure_installation
```
6. Install the Icinga2 IDO Modules for MySQL.
```
yum install icinga2-ido-mysql
```
7. Create a database for the Icinga2 IDO Modules and import the Icinga2 IDO Schema into the database. 
```
mysql -u root -p
# Inside MariaDB (MySQL)
# Feel free to substitute your own database names/passwords
MariaDB> CREATE DATABASE icinga2;
MariaDB> GRANT ALL PRIVILEGES ON icinga2.* TO icinga2@localhost IDENTIFIED BY 'icinga123';
MariaDB> FLUSH PRIVILEGES;
MariaDB> EXIT;
# Outside of MariaDB
mysql icinga2 < /usr/share/icinga2-ido-mysql/schema/mysql.sql
```
8. Enable necessary features in Icinga2.
```
icinga2 feature enable ido-mysql command
```
9. Configure the firewall.
```
firewall-cmd --permanent --add-port=5665/tcp --zone=public
firewall-cmd --reload
```
10. (CHPC/SNMP Specific) Copy files to correct locations to allow for better SNMP-based monitoring.
```

```
11. Restart Icinga2.
```
systemctl restart icinga2
```
