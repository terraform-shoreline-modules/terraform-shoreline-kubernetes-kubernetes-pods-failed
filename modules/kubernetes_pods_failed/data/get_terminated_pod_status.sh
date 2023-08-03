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