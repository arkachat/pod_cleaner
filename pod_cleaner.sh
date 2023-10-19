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

# Register the cleanup function for script exit
trap cleanup EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGTERM

# Function to delete all pods in a namespace
delete_pods_in_namespace() {
    local namespace=$1
    echo "Deleting all pods in namespace $namespace"
    kubectl delete pods --all -n "$namespace"
}

# Retrieve all namespaces, excluding those that contain "kube-"
kubectl get namespaces -o name | grep -v "kube-" | awk -F "/" '{print $2}' | while read -r namespace ; do
    # Delete all pods in the current namespace
    delete_pods_in_namespace "$namespace" &
    
    # Allow only 10 jobs in parallel
    while (( $(jobs | wc -l) >= 10 )); do
        # Wait for any job to finish before starting a new one
        wait -n
    done
done

# Wait for all background jobs to finish
wait

