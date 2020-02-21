# Grafana/Influx Configuration for Icinga2

## Installation

1. Begin by installing Grafana. Instructions for doing so (on CentOS) can be found [here](https://grafana.com/docs/grafana/latest/installation/rpm/). I've also copied over the commands for convenience.

```

```



1. Then, install InfluxDB. Instructions for doing so can be found [here](https://docs.influxdata.com/influxdb/v1.7/introduction/installation/); make sure to select the correct installation guide for your OS. 
2. Open up required ports. The command assumes the use of default port numbers for Grafana (3000) and InfluxDB (8086/8088). 

```
firewall-cmd --add-port={3000,8086,8088}/tcp --zone=public --permanent
firewall-cmd --reload
```

4.  

