#!/bin/bash

# Nmap automated testing for optimal parallel settings with timeout

# Network to scan (edit this to your target networks)
NETWORK="192.168.0.0/21"
OUTPUT_DIR="./nmap_results"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Parameters to test
MIN_HOSTGROUP_VALUES=(16 32 64 128)
MAX_RATE_VALUES=(50 100 200 300 500)

# Timing template (can be adjusted)
TIMING="-T4"

# Timeout for each scan (e.g., 10 minutes)
SCAN_TIMEOUT="600s"

# Start testing
echo "Starting Nmap rate test on $NETWORK with timeout $SCAN_TIMEOUT"
echo "Results will be saved in $OUTPUT_DIR"

# Loop through combinations of min-hostgroup and max-rate
for MIN_HOSTGROUP in "${MIN_HOSTGROUP_VALUES[@]}"; do
    for MAX_RATE in "${MAX_RATE_VALUES[@]}"; do
        # Generate output file name
        OUTPUT_FILE="${OUTPUT_DIR}/scan_min${MIN_HOSTGROUP}_rate${MAX_RATE}.txt"

        echo "Running scan: --min-hostgroup=$MIN_HOSTGROUP --max-rate=$MAX_RATE (timeout: $SCAN_TIMEOUT)"
        echo "Output: $OUTPUT_FILE"

        # Run Nmap scan with timeout
        timeout "$SCAN_TIMEOUT" nmap -sS $TIMING --min-hostgroup $MIN_HOSTGROUP --max-rate $MAX_RATE -oN "$OUTPUT_FILE" "$NETWORK"

        # Check if the scan timed out
        if [ $? -eq 124 ]; then
            echo "Scan with --min-hostgroup=$MIN_HOSTGROUP --max-rate=$MAX_RATE timed out after $SCAN_TIMEOUT" | tee -a "$OUTPUT_FILE"
        fi

        # Sleep for a short duration to avoid overwhelming the network
        sleep 5
    done
done

echo "Nmap rate testing completed. Check results in $OUTPUT_DIR."
