# BMI Repository
## UofU CHPC - Created for Randy Madsen @ Biomedical Informatics

Contains scripts and information required to setup the tools currently used to monitor BMI devices. These tools include Icinga2/IcingaWeb2, Grafana, InfluxDB, and SNMP. Unless otherwise specified, these instructions assume the use of CentOS 7 as the OS and bash as the shell language.

Contents:
- icinga.d: Contains information relevant to setting up Icinga2/IcingaWeb2. As part of that, it also includes the instructions for setting up SNMP to work with the Nagios plugins we use at CHPC to check things like RAM and CPU usage, load, and other things.
- frontend.d: Contains information relevant to setting up Grafana and InfluxDB. Some information here will be replicated in icinga.d; specifically, instructions for setting up InfluxDB to work with Icinga2 will be found in both directories. 
