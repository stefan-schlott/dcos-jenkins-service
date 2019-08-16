#!/bin/bash
set -x
#Cleanup scripts if needed
#cls; DCOS_LOGIN_USERNAME="dcos-dev" DCOS_LOGIN_PASSWORD="dogfoodinit" PYTEST_ARGS="--service-ids=jenkins1,jenkins7" ./test.sh -m scalecleanup jenkins

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
LOG_DIR=$DIR/logs
mkdir -p $LOG_DIR

LOGFILE=$LOG_DIR/jenkins_log_`date +%Y%M%d_%H%M%S`.log

#DCOS_LOGIN_USERNAME="bootstrapuser"
#DCOS_LOGIN_PASSWORD="deleteme" 

DCOS_LOGIN_USERNAME="dcos-dev"
DCOS_LOGIN_PASSWORD="dogfoodinit" 


#Ensure we're running with the correct Jenkins version.
#dcos package repo add --index=0 jenkins-aws "${STUB_UNIVERSE_URL}"

dcos package repo remove jenkins-mwt
export STUB_UNIVERSE_URL='https://universe-converter.mesosphere.com/transform?url=https://infinity-artifacts.s3.amazonaws.com/permanent/jenkins/assets/scale-test-jenkins-2.150.1/stub-universe-jenkins.json'
dcos package repo add --index=0 jenkins-mwt $STUB_UNIVERSE_URL


SLEEP_TIME=60
RUN_DELAY=$SLEEP_TIME
WORK_DURATION=$(( $SLEEP_TIME*60 ))

SINGLE_USE=True
#CREATE_FRAMEWORK=True
#CREATE_JOBS=False

CREATE_FRAMEWORK=False
CREATE_JOBS=True

cls; 

#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=0 --max=25 --batch-size=25 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=25 --max=100 --batch-size=25 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE

#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=100 --max=200 --batch-size=50 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE

#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=200 --max=500 --batch-size=100 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=500 --max=1000 --batch-size=100 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=1000 --max=1500 --batch-size=100 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE



#Patch ups.
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=2001 --max=2004 --batch-size=3 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=2004 --max=2006 --batch-size=2 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=2006 --max=2007 --batch-size=1 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=2007 --max=2018 --batch-size=10 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE

#CREATE_JOBS=True
#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=2000 --max=2001 --batch-size=1 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE


#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=25 --max=100 --batch-size=25 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#sleep 120

#for i in $(seq 100 100 1400); do
        #MIN=$i
        #MAX=$(( $i+100 ))       

		#PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=$MIN --max=$MAX --batch-size=100 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
		#sleep 120 
#done

		
PYTEST_ARGS="--jobs=5 --work-duration=$WORK_DURATION --scenario=sleep --min=2001 --max=2019 --batch-size=20 --run-delay=$RUN_DELAY --create-framework=$CREATE_FRAMEWORK --create-jobs=$CREATE_JOBS --single-use=$SINGLE_USE" ./test.sh -m scale jenkins |& tee -a $LOGFILE
