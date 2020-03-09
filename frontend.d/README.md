# Grafana/Influx Configuration for Icinga2

## Installation

1. Begin by installing Grafana. Instructions for doing so (on CentOS) can be found [here](https://grafana.com/docs/grafana/latest/installation/rpm/). I've also copied over the commands for convenience.
```
cat <<EOF | sudo tee /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

sudo yum install -y grafana
sudo systemctl enable grafana-server --now
```
I was running into some issues with the Grafana repository; specifically, it would occasionally fail with "[Errno 14] curl#60 - ...". I fixed this by changing the line `sslverify=1` to `sslverify=0`. 

2. Then, install InfluxDB. Instructions for doing so can be found [here](https://docs.influxdata.com/influxdb/v1.7/introduction/installation/); make sure to select the correct installation guide for your OS. I've copied over the commands for convenience.
```
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

sudo yum install -y influxdb
sudo systemctl enable influxdb --now
```
3. Open up required ports. The command assumes the use of default port numbers for Grafana (3000) and InfluxDB (8086/8088). 
```
firewall-cmd --add-port={3000,8086,8088}/tcp --zone=public --permanent
firewall-cmd --reload
```
4. Install the InfluxDB Writer for Icinga2 and restart Icinga2. 
```
sudo icinga2 feature enable influxdb
sudo systemctl restart icinga2
```
5. Create a new database for the InfluxDB Writer to write to. Feel free to replace the password with something more secure. 
```
sudo influx
Influx> CREATE DATABASE icinga2;
Influx> CREATE USER icinga2 WITH PASSWORD 'icinga123';
```
6. Configure InfluxDB Writer. Open `/etc/icinga2/features-enabled/influxdb.conf` with a text editor of your choice and replace the contents with the following:
```
host = "<influx_host_address>"
port = 8086
database = "icinga2"
username = "icinga2"
password = "icinga123"
enable_send_thresholds = true
enable_send_metadata = true
flush_threshold = 1024
flush_interval = 10s
host_template = {
  measurement = "$host.check_command$"
  tags = {
    hostname = "$host.name$"
  }
}
service_template = {
  measurement = "$service.check_command$"
  tags = {
    hostname = "$host.name$"
    service = "$service.name$"
  }
}
```
Then, restart Icinga2. 
```
systemctl restart icinga2
```
7. Go to the Grafana homepage; this will be located at \<host ip\>:3000. Login; by default the credentials are admin/admin, but you will be required to change the password upon the first login. After successfully logging in, add the InfluxDB datasource by going to Configuration > Data Sources > Add New Data Source. Select InfluxDB from the list of possible data sources. In all of my testing, I ran InfluxDB and Grafana on the same server. With this setup, the settings are as follows:
  - URL: http://localhost:8086
  - Access: Server
  - All toggles unchecked
  - Database: \<database name\> (step 5)
  - Username: \<database username\> (step 5)
  - Password: \<database password\> (step 5)
Save and test the connection; it should be able to connect without any issues. If it's unable to connect, make sure the username/password is correct for the InfluxDB database and that the firewall is permitting traffic to 8086/tcp. 
  


