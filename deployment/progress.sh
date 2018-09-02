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



NAMESPACE=$1
if [[ -z ${NAMESPACE} ]];then
  NAMESPACE=default
fi
export NAMESPACE

function count(){
  local i=0
  for E in $1;
  do
    i=$((i + 1))
  done
  echo "$i"
}

function podCount(){
  local POD_STATUSES=$(kubectl -n ${NAMESPACE} get pods -o jsonpath='{.items[*].status.phase}')
  echo $(count "$POD_STATUSES")
}

function runningPodCount(){
  local POD_STATUSES=$(kubectl -n ${NAMESPACE} get pods -o jsonpath='{.items[?(@.status.phase=="Running")].status.conditions[?(@.type=="Ready")].status}')
  local i=0
  for E in $POD_STATUSES;
  do
    if [[ ${E} = "True" ]];then
      i=$((i + 1))
    fi
  done
  echo "$i"
}

i=1
sp="/-\|"
echo -n ' '
while true;
do
  total=$(podCount)
  ready=$(runningPodCount)

  if [[ ${total} -eq ${ready} ]];then
    printf "\rAll ${total} pods are ready.                                                       "
    echo
    exit 0
  else
    printf "\r${ready} \tout of \t${total} pods started\t\t${sp:i++%${#sp}:1}"
  fi
done
