#!/bin/bash

export NAMESPACE_NAME="ewps-k8s"
#kubectl create namespace "$NAMESPACE_NAME"
#kubectl --namespace="$NAMESPACE_NAME" create role pod-manager-role   --verb=create,patch,delete,list,watch --resource=pods
#kubectl --namespace="$NAMESPACE_NAME" create role log-reader-role   --verb=get,list --resource=pods/log
#kubectl --namespace="$NAMESPACE_NAME" create rolebinding pod-manager-default-binding   --role=pod-manager-role --serviceaccount=${NAMESPACE_NAME}:default
#kubectl --namespace="$NAMESPACE_NAME" create rolebinding log-reader-default-binding   --role=log-reader-role --serviceaccount=${NAMESPACE_NAME}:default

kubectl --namespace="$NAMESPACE_NAME" create -f ewps-k8s/ewps-k8s-volume-claim.yaml
kubectl --namespace="$NAMESPACE_NAME" create -f ewps-k8s/ewps-k8s-stage-input-data.yaml
kubectl --namespace="$NAMESPACE_NAME" get pods
_stage_in_id=$(kubectl --namespace="$NAMESPACE_NAME" get pods | grep ewps-k8s-stage-input-data | cut -d" " -f1)
kubectl --namespace="$NAMESPACE_NAME" cp NDVI-Stacker/NDVI-Stacker.cwl ${_stage_in_id}:/ewps/app/
kubectl --namespace="$NAMESPACE_NAME" cp NDVI-Stacker/NDVI-Stacker-input.cwl ${_stage_in_id}:/ewps/app/
kubectl --namespace="$NAMESPACE_NAME" cp NDVI-Stacker/input/img1.tif ${_stage_in_id}:/ewps/app/
kubectl --namespace="$NAMESPACE_NAME" cp NDVI-Stacker/input/img2.tif ${_stage_in_id}:/ewps/app/
kubectl --namespace="$NAMESPACE_NAME" create -f ewps-k8s/ewps-k8s.yaml
echo "-- Waiting for k8s job to start (10s)";sleep 10
kubectl --namespace="$NAMESPACE_NAME" logs -f job.batch/ewps-k8s
kubectl --namespace="$NAMESPACE_NAME" cp ${_stage_in_id}:/ewps/app/out.tif ./out.tif 
kubectl --namespace="$NAMESPACE_NAME" delete -f ewps-k8s/ewps-k8s.yaml
kubectl --namespace="$NAMESPACE_NAME" delete -f ewps-k8s/ewps-k8s-stage-input-data.yaml
echo "-- done. Check out.tif"