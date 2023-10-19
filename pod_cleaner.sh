#!/bin/bash

# Define lock file location
LOCKFILE="/tmp/pod_cleaner.lock"

# Check if lock file exists at script start
if [ -f "$LOCKFILE" ]; then
    echo "Lock file exists, previous run not finished. Exiting."
    exit 1
fi

# Create lock file
touch $LOCKFILE

# Define cleanup procedure
cleanup() {
    echo "Cleaning up..."
    rm -f $LOCKFILE
    exit
}

# Register the cleanup function for script exit, SIGHUP, SIGINT, SIGQUIT, SIGABRT, SIGTERM
trap cleanup EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM

# Your existing script logic starts here

# List of namespaces to ignore
IGNORE_NAMESPACES=(kube-system)

# Function to check if an item exists in an array
in_array() {
    local needle=$1
    shift
    local item
    for item in "$@"; do
        [[ $item == $needle ]] && return 0 # 0 is the success exit status in bash
    done
    return 1 # 1 is the general failure exit status in bash
}

# Get all namespaces
NAMESPACES=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

for NAMESPACE in $NAMESPACES; do
    # Skip the ignored namespace with IGNORED_NAMESPACES variable
    if in_array "$NAMESPACE" "${IGNORE_NAMESPACES[@]}"; then
        echo "Skipping namespace $NAMESPACE"
        continue
    fi

    # Get all pods in the namespace that are not in 'Running' or 'Init' state
    PODS=$(kubectl get pods -n $NAMESPACE -o jsonpath='{.items[?(@.status.phase!="Running" && @.status.phase!="Succeeded")].metadata.name}')

    for POD in $PODS; do
        echo "Restarting pod $POD in namespace $NAMESPACE"
        kubectl delete pod "$POD" -n "$NAMESPACE"
    done
done