#!/bin/bash
#
# Copyright (c) Istituto Nazionale di Fisica Nucleare, 2018.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <seAlias> <additionalRobotArguments>"
  exit 1
fi

target_se=$1
shift

DAV_HOST=${DAV_HOST:-localhost}

REMOTE_DAV_HOST=${REMOTE_DAV_HOST:-${DAV_HOST:-localhost}}

REPORTS_DIR=${REPORTS_DIR:-"reports/${target_se}"}

ROBOT_ARGS=${ROBOT_ARGS:-}

DEFAULT_ARGS="--pythonpath .:common --variable dav.host:${DAV_HOST} --variable remote.dav.host:${REMOTE_DAV_HOST} -d ${REPORTS_DIR}"

read -a ARGS <<< "${DEFAULT_ARGS} ${ROBOT_ARGS}"
ARGS+=("$@")

export REQUESTS_CA_BUNDLE=${REQUESTS_CA_BUNDLE:-/etc/grid-security/certificates}

echo "JWT compliance test suite run against: ${target_se}"
robot "${ARGS[@]}" --variable se_alias:${target_se} --name ${target_se} -G ${target_se} test 
