#!/bin/bash

# Function to check internet connectivity
check_internet() {
    # Array of servers to ping
    local servers=("8.8.8.8" "1.1.1.1")
    local attempts=3

    for server in "${servers[@]}"; do
        echo "Checking internet connectivity with $server"
        for attempt in $(seq 1 $attempts); do
            if ping -c 1 $server &> /dev/null; then
                echo "Internet is up (successful ping to $server)"
                return 0 # Internet is up
            else
                echo "Attempt $attempt of $attempts to ping $server failed"
            fi
        done
    done

    echo "Internet is down (all servers unreachable)"
    return 1 # Internet is down
}


turn_off_plug() {
	hs100 $MODEM_PLUG_IP off
}

turn_on_plug() {
	hs100 $MODEM_PLUG_IP on
}

# Main logic
if hs100 $MODEM_PLUG_IP info; then
	echo "Modem rebooter started and pointed to HS100 at $MODEM_PLUG_IP"
	while true; do
		if ! check_internet; then
			echo "Internet is down, cycling power on HS100..."
			echo "Turning off plug..."
			turn_off_plug
			sleep 10
			echo "Turning on plug..."
			turn_on_plug
		fi
		sleep 300
	done
else
	echo "Modem rebooter cannot communicate with plug. Cannot continue."
fi
