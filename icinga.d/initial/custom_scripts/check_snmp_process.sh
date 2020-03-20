#!/bin/bash

# Andrew Golightly
# August 2019
# Checks to see if a certain process is running via snmp

# Used for pretty formatting of results. 
RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m'

# Function to print out help dialog. Created to reduce redundant code. 
print_help() {
    echo "Usage:"
    echo -e "\t-h: Print this dialog (help)."
    echo -e "\t-c: SNMPv2c community string."
    echo -e "\t-p: Process name to be checked."
    echo -e "\t-t: Target host IP address."
    echo -e "Example usage: \"check_snmp_process -t localhost -c public -p httpd\" will check the local machine (localhost) for a running instance of the httpd process."
}

# Rudimentary check for the proper number of arguments (should be 6?)
if [ $1 == '-h' ]
then
    print_help
    exit 3
elif [ $# -ne 6 ]
then
    echo "Missing arguments."
    print_help
    exit 3
else
    :
fi

# Processes the arguments - there are 3, one for community string (assuming v2c for now)
# and another for the process name. 
while getopts "c:p:t:" opt; do
    case $opt in
	c)
	    COMMUNITY_STR=$OPTARG
	    ;;
	p)
	    PROCESS=$OPTARG
	    ;;
	t)
	    HOST=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 3
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 3
	    ;;
    esac
done

# Gets result of command. Uses egrep to reduce/eliminate false positives (i.e. ssh and ssh-agent both match when using 
# just grep).
RESULT=$((snmpwalk -v2c -c $COMMUNITY_STR $HOST hrSWRunName) 2>&1)

if [ -z "$(echo "$RESULT" | grep "No Response")" ]
then
    :
else
    echo "Unable to reach $HOST via SNMP query. Check /etc/snmp/snmpd.conf on the host machine and make sure snmpd is running."
    exit 3
fi

# Result is equal to the number of processes running. 
RESULT=$(echo "$RESULT" | egrep "\"$PROCESS\"" | wc -l)
 
# RESULT=$(snmpwalk -v2c -c $COMMUNITY_STR $HOST hrSWRunName | egrep "\"$PROCESS\"")

# Checks to see if result is empty. If it is, then the process isn't running and the script 
# returns a "critical" status. Otherwise, it is assumed that the process is in fact running, in which case
# it returns an "OK" status. Also prints a single line, in accordance with Nagios plugin guide. 
if [ "$RESULT" -eq 0 ]
then
    echo "PROCS CRITICAL: 0 processes with command name '$PROCESS' | procs=$RESULT;;1:;0;"
    exit 2
else
    echo "PROCS OK: $RESULT processes with command name '$PROCESS' | procs=$RESULT;;1:;0;"
    exit 0
fi


#PROCS OK: 3 processes with command name 'sshd' | procs=3;;;0;

# Pretty version for console output - however it doesn't play nice with nagios so we aren't using it :(
# if [ -z "$RESULT" ]
# then
#     echo -e "${RED}ERROR:${NC} $PROCESS is NOT running on $HOST"
#     exit 2
# else
#     echo -e "${GREEN}SUCCESS:${NC} $PROCESS is running on $HOST"
#     exit 0
# fi
