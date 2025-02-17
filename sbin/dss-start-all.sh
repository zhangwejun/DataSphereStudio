#!/usr/bin/env bash
#
# Copyright 2019 WeBank
#
# Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Start all dss applications
info="We will start all dss applications, it will take some time, please wait"
echo ${info}

#Actively load user env


cd `dirname $0`
cd ..
INSTALL_HOME=`pwd`

# set DSS_HOME
if [ "$DSS_HOME" = "" ]; then
  export DSS_HOME=$INSTALL_HOME
fi

# set DSS_CONF_DIR
if [ "$DSS_CONF_DIR" = "" ]; then
  export DSS_CONF_DIR=$DSS_HOME/conf
fi

local_host="`hostname --fqdn`"
source $DSS_HOME/sbin/common.sh
source $DSS_CONF_DIR/config.sh

function startApp(){
echo "<-------------------------------->"
echo "Begin to start $SERVER_NAME"
SERVER_START_CMD="sh $DSS_INSTALL_HOME/sbin/dss-daemon.sh restart $SERVER_NAME"
if test -z "$SERVER_IP"
then
  SERVER_IP=$local_host
fi
executeCMD $SERVER_IP "$SERVER_START_CMD"
echo "End to start $SERVER_NAME"
echo "<-------------------------------->"
sleep 1
}

function checkServer() {
echo "<-------------------------------->"
echo "Begin to check $SERVER_NAME"
SERVER_CHECK_CMD="sh $DSS_HOME/sbin/dss-daemon.sh status $SERVER_NAME"
if test -z "$SERVER_IP"
then
  SERVER_IP=$local_host
fi

executeCMD $SERVER_IP "$SERVER_CHECK_CMD"

if [ $? -ne 0 ]; then
      ALL_SERVER_NAME=$SERVER_NAME
      LOG_PATH=$DSS_HOME/logs/$ALL_SERVER_NAME.log
      echo "ERROR: your $ALL_SERVER_NAME microservice is not start successful !!! ERROR logs as follows :"
      echo "Please check  detail log, log path :$LOG_PATH"
      echo '<---------------------------------------------------->'
      executeCMD $ALL_SERVER_NAME "tail -n 50 $LOG_PATH"
      echo '<---------------------------------------------------->'
      echo "Please check  detail log, log path :$LOG_PATH"
      exit 1
fi
echo "<-------------------------------->"
sleep 3
}


function startDssProject(){
	SERVER_NAME=dss-framework-project-server
	SERVER_IP=$DSS_FRAMEWORK_PROJECT_SERVER_INSTALL_IP
	startApp
	sleep 5

# echo "------------------------Start to check whether the project service is registered to eureka successfully-----------------------------"
#  #project服务启动并注册到eureka后再启动其他服务
#  i=1
#  while [[ -z $result ]] && [[ $i -le 24 ]]
#  do
#    sleep 5
#    if [ -z $EUREKA_USERNAME ] || [ -z $EUREKA_PASSWORD ];then
#        response=`curl  http://${EUREKA_INSTALL_IP}:${EUREKA_PORT}/eureka/apps/DSS-FRAMEWORK-PROJECT-SERVER`
#    else
#        response=`curl  http://${EUREKA_USENAME}:${EUREKA_PASSWORD}@${EUREKA_INSTALL_IP}:${EUREKA_PORT}/eureka/apps/DSS-FRAMEWORK-PROJECT-SERVER`
#    fi
#    let i++
#  result=$(echo $response |grep 'DSS-FRAMEWORK-PROJECT-SERVER')
#  done
#  if [[ $i -eq 25 ]]; then
#      echo "the project server start failed in two minutes,please check the log to find more error details."
#      exit
#  fi
#  echo "------------------------the project service is registered to eureka successfully------------------------------------------------"

	SERVER_NAME=dss-apiservice-server
	SERVER_IP=$DSS_APISERVICE_SERVER_INSTALL_IP
	startApp

	SERVER_NAME=dss-scriptis-server
  SERVER_IP=$DSS_SCRIPTIS_SERVER_INSTALL_IP
  startApp

	SERVER_NAME=dss-flow-execution-server
	SERVER_IP=$DSS_FLOW_EXECUTION_SERVER_INSTALL_IP
	startApp

	SERVER_NAME=dss-data-api-server
	SERVER_IP=$DSS_DATA_API_SERVER_INSTALL_IP
	startApp

  SERVER_NAME=dss-data-governance-server
	SERVER_IP=$DSS_DATA_GOVERNANCE_SERVER_INSTALL_IP
  startApp

  SERVER_NAME=dss-guide-server
	SERVER_IP=$DSS_GUIDE_SERVER_INSTALL_IP
  startApp

  SERVER_NAME=dss-framework-orchestrator-server
	SERVER_IP=$DSS_FRAMEWORK_ORCHESTRATOR_SERVER_INSTALL_IP
	startApp

	SERVER_NAME=dss-workflow-server
	SERVER_IP=$DSS_WORKFLOW_SERVER_INSTALL_IP
	startApp

}

function checkDssService(){
	SERVER_NAME=dss-framework-project-server
	SERVER_IP=$DSS_FRAMEWORK_PROJECT_SERVER_INSTALL_IP
	checkServer

	SERVER_NAME=dss-framework-orchestrator-server
	SERVER_IP=$DSS_FRAMEWORK_ORCHESTRATOR_SERVER_INSTALL_IP
	checkServer

	SERVER_NAME=dss-apiservice-server
	SERVER_IP=$DSS_APISERVICE_SERVER_INSTALL_IP
	checkServer

	SERVER_NAME=dss-scriptis-server
  SERVER_IP=$DSS_SCRIPTIS_SERVER_INSTALL_IP
  checkServer

	SERVER_NAME=dss-workflow-server
	SERVER_IP=$DSS_WORKFLOW_SERVER_INSTALL_IP
	checkServer

	SERVER_NAME=dss-flow-execution-server
	SERVER_IP=$DSS_FLOW_EXECUTION_SERVER_INSTALL_IP
	checkServer

	SERVER_NAME=dss-data-api-server
  SERVER_IP=$DSS_DATA_API_SERVER_INSTALL_IP
  checkServer

  SERVER_NAME=dss-guide-server
  SERVER_IP=$DSS_GUIDE_SERVER_INSTALL_IP
  checkServer
}



startDssProject
checkDssService