# Icinga2 Configuration File Setup

The "full" subdirectory contains examples of the services, commands, and (anonymized) hosts that we use at CHPC.

## Adding hosts

1. Begin by finding the IP address of the host you wish to add. You may also be able to use the FQDN, but I've run into a lot of issues trying to do that and have opted to just use the IP.
```
# On host device
ip -A
```
2. If you want to