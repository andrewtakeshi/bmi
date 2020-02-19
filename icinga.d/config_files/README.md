# Icinga2 Configuration File Setup

The "full" subdirectory contains examples of the services, commands, and (anonymized) hosts that we use at CHPC.

This is by no means a comprehensive guide; for more information, view the [Icinga2 documentation](https://icinga.com/docs/icinga2/latest/doc/04-configuration/).

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

- By default, located in `/etc/icinga2/conf.d/templates.conf`.
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
- Templates can be configured for hosts, services, notifications, etc. 

## Commands
- By default, commands are located in `/etc/icinga2/conf.d/commands.conf`
- Commands are what we use to configure new services/checks. As an example, we're going to walk through the process of adding [check_num_procs_snmp.sh](https://github.com/andrewtakeshi/bmi/blob/master/icinga.d/initial/custom_scripts/check_num_procs_snmp.sh) to our system. check_num_procs_snmp.sh is a simple bash script which uses SNMP to check the number of currently running processes on a remote machine. I wrote it as a way to explore both SNMP based monitoring and implement Nagios Plugin standards; it should be legible enough to recreate and modify to fit other simple SNMP based monitoring tasks. 

```
object CheckCommand "snmp_num_procs" {
  command = [ PluginDir + "/check_num_procs_snmp.sh" ]
  
  arguments = {
  "-t" = "$addr$"
  "-c" = "$comm$"
  "-W" = "$warn$"
  "-C" = "$crit$"
  }
}
```

- The command name, "snmp_num_procs" will be used when setting up the service. 
- `command = ...` specifies the location of the script. In my installation, check_num_procs_snmp.sh is located at `/usr/lib64/nagios/plugins/check_num_procs_snmp.sh`. `PluginDir` refers to the first part of this, `/usr/lib64/nagios/plugins`, and is automatically configured by Icinga2. Constants can be modified or added in `/etc/icinga2/conf.d/constants.conf`, as detailed in the documentation. 
- `arguments = { ... }` is a dictionary corresponding to the script arguments. Because this script uses SNMP v2, it requires an IP address `(-t:addr)` and a community string `(-c:comm)`. Additionally, as a Nagios script it has configurable warning `(-W:warn)` and critical thresholds `(-C:crit)`. 

## Services
- By default, services are located in `/etc/icinga2/conf.d/services.conf`
- Services are applied to hosts and are what actually run the commands (at least in my understanding).
- Continuing with the example from the **Commands** section:
```
apply Service "num-procs" {
  import "generic-service"
  
  vars.addr = host.address
  vars.comm = host.vars.commstr
  vars.warn = host.vars.procs_warn
  vars.crit = host.vars.procs_crit
  vars.check_command = "procs"
  
  check_command = "snmp_num_procs"
  
  assign where host.vars.os == "linux"
}
```

