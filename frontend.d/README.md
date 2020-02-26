# Grafana/Influx Configuration for Icinga2

## Installation

1. Begin by installing Grafana. Instructions for doing so (on CentOS) can be found [here](https://grafana.com/docs/grafana/latest/installation/rpm/). I've also copied over the commands for convenience.
```
cat <<EOF | sudo tee /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/enterprise/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt

sudo yum install -y grafana
sudo systemctl enable grafana-server --now
```
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
4. Install the InfluxDB Writer for Icinga2
```
icinga2 feature enable influxdb
```



