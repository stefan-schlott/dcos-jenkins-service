#!/bin/bash

#Cleanup scripts if needed
#cls; DCOS_LOGIN_USERNAME="dcos-dev" DCOS_LOGIN_PASSWORD="dogfoodinit" PYTEST_ARGS="--service-ids=jenkins1,jenkins7" ./test.sh -m scalecleanup jenkins

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
LOG_DIR=$DIR/logs
mkdir -p $LOG_DIR

LOGFILE=$LOG_DIR/jenkins_log_`date +%Y%M%d_%H%M%S`.log

DCOS_LOGIN_USERNAME="bootstrapuser"
DCOS_LOGIN_PASSWORD="deleteme" 

#Ensure we're running with the correct Jenkins version.
#dcos package repo add --index=0 jenkins-aws "${STUB_UNIVERSE_URL}"

dcos package repo remove jenkins-mwt
export STUB_UNIVERSE_URL='https://universe-converter.mesosphere.com/transform?url=https://infinity-artifacts.s3.amazonaws.com/permanent/jenkins/assets/scale-test-jenkins-2.150.1/stub-universe-jenkins.json'
dcos package repo add --index=0 jenkins-mwt $STUB_UNIVERSE_URL

WORK_DURATION=600
SINGLE_USE=True
CREATE_FRAMEWORK=True
CREATE_JOBS=False


cls; 

#PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=0 --max=5 --batch-size=5 --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=5 --max=25 --batch-size=20 --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=25 --max=100 --batch-size=25 --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE

#PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=100 --max=200 --batch-size=50 --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=200 --max=1500 --batch-size=100 --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE



