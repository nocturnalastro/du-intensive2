#!/bin/bash

# ==============================================================================
#  Concurrent iperf3 and nftables Monitoring Script
#
#  Description:
#  This script runs iperf3 in either client or server mode while also
#  periodically monitoring nftables rules in the background. All outputs are
#  sent to log files, which are then tailed for a real-time view.
#
#  Usage:
#  1. Save this script as a file (e.g., monitor.sh).
#  2. Make the script executable: chmod +x monitor.sh
#  3. Run the script with arguments:
#     ./monitor.sh <mode> <ip_address> [bandwidth] [time]
#
#     - mode: 'client' or 'server'. (Required)
#     - ip_address: IP for client to connect to, or for server to bind to. (Required)
#     - bandwidth: Bandwidth for client mode (e.g., 1G, 2500M). (Default: 2500M)
#     - time: Duration for client mode in seconds, or 'inf' for infinite. (Default: inf)
#
#  Examples:
#     - Client Mode: ./monitor.sh client 192.168.1.10
#     - Client with 1G bandwidth for 60s: ./monitor.sh client 192.168.1.10 1G 60
#     - Server Mode: ./monitor.sh server 192.168.1.10
#
#  Note: The 'nft' command and running iperf3 in server mode might require
#  root privileges. If so, run the script with 'sudo'.
# ==============================================================================

# --- Log File Configuration ---
# Define paths for the log files. These will be created in /tmp/.
IPERF_LOG="/tmp/iperf3_monitor.log"
NFT_LOG="/tmp/nft_monitor.log"


# Set variables from command-line arguments.
MODE=$1
SERVER_IP=$2
BANDWIDTH=${3:-2500M} # Default will be used if $3 is not provided
TIME=${4:-inf}      # Default will be used if $4 is not provided

# Validate the mode
if [[ "$MODE" != "client" && "$MODE" != "server" ]]; then
  echo "Error: Invalid mode '$MODE'. Must be 'client' or 'server'."
  echo "Usage: $0 <client|server> <ip_address> [bandwidth] [time]" >&2
  exit 1
fi

# Announce settings
echo "Mode selected: $MODE"
echo "IP Address: $SERVER_IP"
if [[ "$MODE" == "client" ]]; then
    echo "Client Bandwidth: $BANDWIDTH"
    echo "Client Time: $TIME"
fi

# --- Background Task Definitions ---

# This function runs iperf3 in a loop, redirecting all its output to a log file.
# The mode (client/server) and parameters are determined by script arguments.
run_iperf_continuously() {
  # This loop will run indefinitely until the main script is terminated.
  while true; do
    # Group commands and redirect their stdout and stderr to the iperf3 log file.
    {
      if [[ "$MODE" == "server" ]]; then
        echo "[$(date)] Starting iperf3 in SERVER mode, binding to $SERVER_IP"
        iperf3 -s -B "$SERVER_IP"
        echo "[$(date)] iperf3 server process exited. Restarting in 5 seconds..."
      else # Client mode
        echo "[$(date)] Starting iperf3 in CLIENT mode, connecting to server: $SERVER_IP"
        echo "[$(date)]   - Bandwidth: $BANDWIDTH, Time: $TIME"
        # The '-t' argument handles both numeric seconds and 'inf' for infinite.
        iperf3 -c "$SERVER_IP" -b "$BANDWIDTH" -t "$TIME" --bidir -w 256K
        echo "[$(date)] iperf3 client process exited. Restarting in 5 seconds..."
      fi
    } >> "$IPERF_LOG" 2>&1

    # Wait for 5 seconds before restarting the test.
    sleep 5
  done
}

# This function runs the nft command periodically, redirecting output to its log file.
run_nft_command_periodically() {
  # This loop will run indefinitely until the main script is terminated.
  while true; do
    # Group commands and redirect their stdout and stderr to the nft log file.
    {
      echo "-----------------------------------------------------"
      echo "[$(date)] Running 'nft list chain inet filter input'"
      echo "-----------------------------------------------------"
      nft list chain inet filter input
      echo "" # Add a blank line for readability
    } >> "$NFT_LOG" 2>&1

    # Wait for 30 seconds before the next execution.
    sleep 30
  done
}

# --- Cleanup Function ---
# This function is triggered on script exit to terminate background processes.
cleanup() {
  echo # Newline for cleaner exit message
  echo "Signal received. Terminating background processes..."

  # Kill the background iperf3 process if its PID exists.
  if [[ -n "$IPERF_PID" ]]; then
    kill "$IPERF_PID" 2>/dev/null
    echo "Background iperf3 process (PID: $IPERF_PID) stopped."
  fi

  # Kill the background nft process if its PID exists.
  if [[ -n "$NFT_PID" ]]; then
    kill "$NFT_PID" 2>/dev/null
    echo "Background nft process (PID: $NFT_PID) stopped."
  fi

  # Exit the script.
  exit 0
}

# --- Main Script Execution ---

# Check for minimum required arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <client|server> <ip_address> [bandwidth] [time]" >&2
    exit 1
fi

# Trap signals INT (Ctrl+C), TERM (terminate), and EXIT to run the cleanup function.
trap cleanup INT TERM EXIT

# Initialize log files by clearing them or creating them if they don't exist.
echo "Initializing log files..."
> "$IPERF_LOG"
> "$NFT_LOG"
echo "  - iperf3 log: $IPERF_LOG"
echo "  - nft log:    $NFT_LOG"
echo ""

# Start the iperf3 loop in the background and save its PID.
echo "Starting background task to run iperf3..."
run_iperf_continuously &
IPERF_PID=$!
echo "Background iperf3 process started with PID: $IPERF_PID"

# Start the nft monitoring loop in the background and save its PID.
echo "Starting background task to monitor nftables..."
run_nft_command_periodically &
NFT_PID=$!
echo "Background nft process started with PID: $NFT_PID"
echo ""

# The main foreground process is now 'tail'.
# It will follow both log files and print new lines as they are added.
echo "Tailing log files. Press Ctrl+C to stop."
tail -f "$IPERF_LOG" "$NFT_LOG"
