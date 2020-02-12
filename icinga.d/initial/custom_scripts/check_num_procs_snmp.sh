#!/bin/bash


# Function to print out help dialog. Created to reduce redundant code.
print_help() {
    echo "Usage:"
    echo -e "\t-h: Print this dialog (help)."
    echo -e "\t-c: SNMPv2c community string."
    echo -e "\t-t: Target host IP address."
    echo -e "Example usage: \"check_snmp_process -t localhost -c publicd\" will check the local machine (localhost) for all running processes."
}

# Processes the arguments - there are 3, one for community string (assuming v2c for now)
# and another for the process name.
while getopts "c:t:W:C:" opt; do
    case $opt in
        c)
            COMMUNITY_STR=$OPTARG
            ;;
        t)
            HOST=$OPTARG
            ;;
	W)
	    WARN=$OPTARG
	    ;;
	C)
	    CRIT=$OPTARG
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
    RESULT=$(echo "$RESULT" | wc -l)
else
    echo "Unable to reach $HOST."
    exit 3
fi

if [ $RESULT -gt $CRIT ]
then
    echo "PROCS CRITICAL: $RESULT processes | procs=$RESULT;$WARN;$CRIT;0"
    exit 2
elif [ $RESULT -gt $WARN ]
then
    echo "PROCS WARNING: $RESULT processes | procs=$RESULT;$WARN;$CRIT;0"
    exit 1
else
    echo "PROCS OK: $RESULT processes | procs=$RESULT;$WARN;$CRIT;0"
    exit 0
fi

#PROCS OK: 193 processes | procs=193;250;500;0;
#PROCS WARNING: 182 processes | procs=182;100;500;0;
#PROCS CRITICAL: 183 processes | procs=183;100;100;0;
