# zenni
 
Pod Cleaner
Introduction
This Helm chart installs Pod Cleaner in a Kubernetes cluster. Pod Cleaner is designed to monitor and restart any pods that are not in the "running" or "init" state across all namespaces, except "kube-system." This chart deploys Pod Cleaner and optionally the Vertical Pod Autoscaler (VPA) for automating the process of setting container resource requests.

Prerequisites
Kubernetes 1.12+
Helm 3.1.0
VPA CRD/controller installed if VPA is enabled.
Installing the Chart
To install the chart with the release name pod-cleaner:
git clone <this repo>
cd pod-cleaner
kubectl create ns pod-cleaner
helm install pod cleaner -n pod-cleaner ./pod-cleaner-chart


# "Section VPA"

Download the VPA release from the Kubernetes Autoscaler repository.
You'll need to clone the autoscaler repository and check out the appropriate release. For example, to check out version 0.9.2, you would do the following:

bash
Copy code
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler/
git checkout vertical-pod-autoscaler-0.9.2
Ensure that you check out the version that is compatible with your Kubernetes cluster.

Deploy the VPA to your cluster.
Once you have the repository checked out, you can deploy the VPA components to your cluster:

bash
Copy code
./hack/vpa-up.sh
This script will create the VPA CRD, the VPA controller, and associated resources in your cluster.

Verification
After installation, verify that the VPA components are running:

bash
Copy code
kubectl get pods -n kube-system | grep vpa
You should see the VPA pods running:

Copy code
vpa-admission-controller-...
vpa-recommender-...
vpa-updater-...