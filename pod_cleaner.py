import time
from kubernetes import client, config
from kubernetes.client.rest import ApiException
from threading import Lock
import logging

# Configs can be set in Configuration class directly or using helper utility
config.load_kube_config()

v1 = client.CoreV1Api()

def notify_error(pod_name, error_details):
    # This function will handle error notifications.
    # Integrate with email, slack, prometheus, etc.
    # For simplicity, it just prints details.
    print(f"Error: Pod {pod_name} failed to start: {error_details}")

def get_pods_in_namespace(namespace):
    try:
        return v1.list_namespaced_pod(namespace)
    except ApiException as e:
        logging.error(f"Exception when calling CoreV1Api->list_namespaced_pod: {e}")
        return None

def delete_pod(namespace, name):
    try:
        v1.delete_namespaced_pod(name, namespace)
    except ApiException as e:
        logging.error(f"Exception when calling CoreV1Api->delete_namespaced_pod: {e}")
        return False
    return True

def main():
    lock = Lock()
    while True:
        with lock:
            namespaces = []
            try:
                namespaces = v1.list_namespace()
            except ApiException as e:
                logging.error(f"Exception when calling CoreV1Api->list_namespace: {e}")

            cleaned_pods = []

            for namespace in namespaces.items:
                if namespace.metadata.name == "kube-system":
                    continue

                pods = get_pods_in_namespace(namespace.metadata.name)
                if pods is None:
                    continue

                for pod in pods.items:
                    if pod.status.phase not in ("Running", "Init"):
                        if delete_pod(namespace.metadata.name, pod.metadata.name):
                            cleaned_pods.append(pod.metadata.name)
                        else:
                            notify_error(pod.metadata.name, "Could not delete pod")
            
            if cleaned_pods:
                logging.info(f"Cleaned pods: {', '.join(cleaned_pods)}")

        # Sleep for 10 minutes before the next iteration
        time.sleep(600)

if __name__ == '__main__':
    main()
