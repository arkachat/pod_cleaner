#!/bin/bash

# Function to restart a pod
restart_pod() {
  namespace=$1
  pod_name=$2

  # Deleting a pod to restart it, as the deployment/statefulset will create a new pod to replace it.
  kubectl delete pod "$pod_name" -n "$namespace"
}

# Main script
while true; do
  # Get all namespaces
  namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

  for namespace in $namespaces; do
    # Skip the kube-system namespace
    if [ "$namespace" == "kube-system" ]; then
      continue
    fi

    # Get pods that are not in 'Running' or 'Succeeded' state
    pods=$(kubectl get pods -n "$namespace" --field-selector=status.phase!=Running,status.phase!=Succeeded -o jsonpath='{.items[*].metadata.name}')

    for pod in $pods; do
      echo "Restarting pod $pod in namespace $namespace"
      restart_pod "$namespace" "$pod"
    done
  done

  sleep 600
done
