#!/bin/bash
#
# Copyright 2017 Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

if [[ -z $ISTIO_HOME ]];then
  echo "the environment variable ISTIO_HOME is not set, set it to the folder of your istio installation"
  exit -1
fi

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# only ask if in interactive mode
if [[ -t 0 ]];then
  echo -n "namespace ? [default] "
  read -r NAMESPACE
fi

if [[ -z ${NAMESPACE} ]];then
  NAMESPACE=default
fi

echo "using NAMESPACE=${NAMESPACE}"

OUTPUT=$(mktemp)
export OUTPUT
echo "Application is starting up"

kubectl apply -f "$ISTIO_HOME/install/kubernetes/helm/istio/templates/crds.yaml" &>/dev/null
kubectl apply -f "$ISTIO_HOME/install/kubernetes/istio-demo.yaml" &>/dev/null
kubectl label namespace ${NAMESPACE} "istio-injection=enabled" &>/dev/null
kubectl apply -n ${NAMESPACE} -f "$SCRIPTDIR/quickstart.yaml" > "${OUTPUT}" 2>&1
ret1=$?
kubectl apply -n ${NAMESPACE} -f "$SCRIPTDIR/quickstart-gateway.yaml" > "${OUTPUT}" 2>&1
ret2=$?

ret=$((ret1 + ret2))
function cleanup() {
  rm -f "${OUTPUT}"
}

trap cleanup EXIT

if [[ ${ret} -eq 0 ]];then
  cat "${OUTPUT}"
else
  cat "${OUTPUT}"
  exit ${ret}
fi

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export INGRESS_SECURE_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(minikube ip)

sleep .5
$SCRIPTDIR/progress.sh ${NAMESPACE}

echo "pods:"
kubectl -n ${NAMESPACE} get pods
echo
echo "Application started successfully"
echo "why not executing:"
echo "curl http://${INGRESS_HOST}:${INGRESS_PORT}/service-a"
# echo "curl https://${INGRESS_HOST}:${INGRESS_SECURE_PORT}/service-a"