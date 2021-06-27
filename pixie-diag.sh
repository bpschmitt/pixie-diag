#!/bin/bash

# Create a log file
exec > >(tee -a "$PWD/pixie-diag.log") 2>&1

echo ""
echo "*****************************************************"
echo "Checking agent status"
echo "*****************************************************"
echo ""

# Check for px
if ! [ -x "$(command -v px)" ]; then
  echo 'Error: px is not installed.' >&2
  else
  px run px/agent_status
fi

echo ""
echo "*****************************************************"
echo "Check all resources"
echo "*****************************************************"
echo ""

# Get all api-resources
for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); 
do
echo "Resource:" $i;
kubectl -n newrelic get --ignore-not-found ${i};
done

echo ""
echo "*****************************************************"
echo "Checking logs"
echo "*****************************************************"
echo ""

deployments=$(kubectl get deployments -n newrelic | awk '{print $1}' | tail -n +2)

for deployment_name in $deployments
  do
    # Get logs from deployed
    echo ""
    echo "Logs from $deployment_name"
    kubectl logs --tail=20 deployments/$deployment_name -n newrelic
    done

echo ""
echo "*****************************************************"
echo "Checking Kernel Version of nodes"
echo "*****************************************************"
echo ""

nodes=$(kubectl get nodes | awk '{print $1}' | tail -n +2)

for node_name in $nodes
  do
    # Get Kernel version from nodes
    echo ""
    echo "Kernel Version from $node_name"
    kubectl describe node $node_name | grep -i "Kernel Version:"
    done

echo ""
echo "*****************************************************"
echo "Checking pod events"
echo "*****************************************************"
echo ""

pods=$(kubectl get pods -n newrelic | awk '{print $1}' | tail -n +2)

for pod_name in $pods
  do
    # Get events from pods in New Relic namespace
    echo ""
    echo "Events from pod name $pod_name"
    kubectl get events --all-namespaces  | grep -i $pod_name
    done

echo ""
echo "*****************************************************"
echo ""

echo "End pixie-diag"
