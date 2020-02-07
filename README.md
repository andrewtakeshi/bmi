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
3. Add the Icinga2 Official Repository and install Icinga2 as well as the latest nagios plugins package. 
```
rpm --import https://packages.icinga.com/icinga.key
yum install https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm
yum install icinga2 nagios-plugins-all
```
5. Install and start 
