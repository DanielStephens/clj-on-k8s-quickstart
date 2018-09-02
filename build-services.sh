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

set -o errexit

if [ "$#" -ne 1 ]; then
    echo Missing version parameter
    echo Usage: build-services.sh \<version\>
    exit 1
fi

VERSION=$1
SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

eval $(minikube docker-env)

pushd "$SCRIPTDIR/service-a"
  #plain build -- simple hey endpoint
  docker build -t "istio/service-a-v1:${VERSION}" -t istio/service-a-v1:latest \
   --build-arg service_version=hey .
  docker build -t "istio/service-a-v2:${VERSION}" -t istio/service-a-v2:latest \
   --build-arg service_version=hi .
popd

pushd "$SCRIPTDIR/service-b"
  docker build -t "istio/service-b-v1:${VERSION}" -t istio/service-b-v1:latest .
popd

eval "$(docker-machine env -u)"

# pushd "$SCRIPTDIR/mysql"
#   docker build -t "examples-bookinfo-mysqldb:${VERSION}" -t examples-bookinfo-mysqldb:latest .
# popd

# pushd "$SCRIPTDIR/mongodb"
#   docker build -t "examples-bookinfo-mongodb:${VERSION}" -t examples-bookinfo-mongodb:latest .
# popd