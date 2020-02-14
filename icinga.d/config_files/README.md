# Icinga2 Configuration File Setup

The "full" subdirectory contains examples of the services, commands, and (anonymized) hosts that we use at CHPC.

This is by no means a comprehensive guide; for more information, view the Icinga2 documentation. However, it should make a very quick and easy way to check 

## General Information

- By default, Icinga2 recursively includes all files ending with `.conf` inside of `/etc/icinga2/conf.d`. This enables users to rename or add configuration files to suit their preferences.
- This recursive behavior can be disabled by modifying `/etc/icinga2/icinga2.conf` and changing `include_recursive "conf.d"` to `include "conf.d/*.conf` for all configuration files located directly in `/etc/icinga2/conf.d` or `include "conf.d/<file_name(s)>.conf` for specific files inside of `/etc/icinga2/conf.d`.  
- Additional directories can be added as configuration directories by adding the line `include "path_to_directory"` to `/etc/icinga2/icinga2.conf`. Similarly, these can recursively add configuration files by changing `include` to `include_recursive`. 

## Hosts

- Actual host configuration will depend on the type of host to be monitored, what templates have been set up, and what you want to monitor. For CHPC/BMI purposes, we elect to monitor a variety of metrics over SNMP (see Icinga2 installation guide to make sure all necessary plugins are installed if you choose to go this route).
- An example configuration file (without the use of templates) looks something like this, where time_interval is an int followed by a unit of time, i.e. `1h` for 1 hour or  `5m` for 5 minutes. 
```
object Host "<host_display_name>" {
  max_check_attempts = <int>
  check_interval = <time_interval>
  retry_interval = <time_interval>
  check_command = "hostalive"
  address = "<ipv4 address>"
  
  # Optional variables for check commands, apply statements, etc.
}
```

## Templates

- By default, located in `/etc/icinga2/conf.d/templates.conf`. As with hosts, these can 
- Templates give Icinga2 a huge amount of power and make adding new hosts fast and easy. As the name suggests, they contain a template for a type of host. For example, this is the default generic-host template provided by Icinga2:
```
template Host "generic-host" {
  max_check_attempts = 5
  check_interval = 10m
  retry_interval = 2m
  check_command = "hostalive"
}
```
- Then, the actual configuration we need to add a new host using the `generic-host` tmeplate gets reduced to:
```
object Host "<host_name>" {
  import "generic-host"
  address = "<ipv4 address>"
  
  # Optional variables for check commands, apply statements, etc. 
}
```
