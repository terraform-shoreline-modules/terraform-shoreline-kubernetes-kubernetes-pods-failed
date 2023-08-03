
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Pods Failed
---

This incident type relates to a failure of Kubernetes pods, which are a fundamental unit of deployment for containerized applications in Kubernetes. The failure could be related to any number of issues, such as a misconfiguration, a software bug, or a resource constraint. The incident may require immediate attention from a software engineer to resolve the issue and prevent further disruption to the application.

### Parameters
```shell
# Environment Variables

export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export DEPLOYMENT="PLACEHOLDER"

export MEMORY_THRESHOLD="PLACEHOLDER"

export CPU_THRESHOLD="PLACEHOLDER"

export STORAGE_THRESHOLD="PLACEHOLDER"
```

## Debug

### Get the list of pods in the cluster
```shell
kubectl get pods -n ${NAMESPACE}
```

### Check the logs of a pod
```shell
kubectl logs ${POD_NAME} -n ${NAMESPACE}
```

### Describe a pod to get more details about its state and configuration
```shell
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### Check the status of the pod's containers
```shell
kubectl get pods ${POD_NAME} -n ${NAMESPACE} -o jsonpath='{.status.containerStatuses[*].state}'
```

### Get the events related to a pod
```shell
kubectl get events --field-selector involvedObject.name=${POD_NAME} -n ${NAMESPACE}
```

### Check the resource usage of a pod
```shell
kubectl top pod ${POD_NAME} -n ${NAMESPACE}
```
### Resource constraints: If a pod exceeds its resource limits, such as CPU or memory, it may be terminated by Kubernetes.
```shell
bash

#!/bin/bash

# Set the namespace and pod name

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}

# Get the pod status

POD_STATUS=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.phase}')

# If the pod is terminated, check the reason for termination

if [[ "$POD_STATUS" == "Failed" ]]; then

  TERMINATION_REASON=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].lastTerminationReason}')

    # If the reason is related to resource constraints, print the relevant information

  if [[ "$TERMINATION_REASON" == *"out of memory"* ]] || [[ "$TERMINATION_REASON" == *"out of cpu"* ]]; then

    echo "Pod $POD_NAME in namespace $NAMESPACE was terminated due to resource constraints."

    echo "Termination reason: $TERMINATION_REASON"

    # Describe the pod to get more information

    kubectl describe pod $POD_NAME -n $NAMESPACE

  else

    echo "Pod $POD_NAME in namespace $NAMESPACE was terminated, but not due to resource constraints."

    echo "Termination reason: $TERMINATION_REASON"

  fi

fi

```

## Repair
### Verify that the Kubernetes cluster has enough resources available for the pods to run. Check CPU, memory, and storage usage, and make sure that the pods are not being starved for resources.
```shell
bash

#!/bin/bash

# Define the Kubernetes namespace and deployment name

NAMESPACE=${NAMESPACE}

DEPLOYMENT=${DEPLOYMENT}

# Get the current resource usage for the Kubernetes deployment

CPU=$(kubectl top pods --namespace=$NAMESPACE | grep $DEPLOYMENT | awk '{print $2}')

MEMORY=$(kubectl top pods --namespace=$NAMESPACE | grep $DEPLOYMENT | awk '{print $3}')

STORAGE=$(kubectl describe pod $DEPLOYMENT --namespace=$NAMESPACE | grep -E "^Storage" | awk '{print $2}')

# Define the thresholds for resource usage

CPU_THRESHOLD=${CPU_THRESHOLD}

MEMORY_THRESHOLD=${MEMORY_THRESHOLD}

STORAGE_THRESHOLD=${STORAGE_THRESHOLD}

# Check if the resource usage is above the thresholds and remediate if necessary

if [[ $CPU -gt $CPU_THRESHOLD ]]; then

    # Scale up the deployment to increase CPU resources

    kubectl scale deployment $DEPLOYMENT --namespace=$NAMESPACE --replicas=2

elif [[ $MEMORY -gt $MEMORY_THRESHOLD ]]; then

    # Scale up the deployment to increase memory resources

    kubectl scale deployment $DEPLOYMENT --namespace=$NAMESPACE --replicas=2

elif [[ $STORAGE -gt $STORAGE_THRESHOLD ]]; then

    # Delete old pods to free up storage space

    kubectl delete pod $DEPLOYMENT-$(date +%Y%m%d%H%M%S) --namespace=$NAMESPACE

fi


```