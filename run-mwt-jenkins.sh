#!/bin/bash
set -x
#PYTEST_ARGS="\
  #--mom=mom-4 \
  #--jobs=5 \
  #--work-duration=600 \
  #--scenario=sleep \
  #--min=0 \
  #--max=5 \
  #--batch-size=5 \
  #--cpu-quota=900 \
#"\
#./test.sh -m scale jenkins

#Cleanup scripts if needed
#cls; DCOS_LOGIN_USERNAME="dcos-dev" DCOS_LOGIN_PASSWORD="dogfoodinit" PYTEST_ARGS="--service-ids=jenkins1,jenkins7" ./test.sh -m scalecleanup jenkins

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
LOG_DIR=$DIR/logs
mkdir -p $LOG_DIR

LOGFILE=$LOG_DIR/jenkins_log_`date +%Y%M%d_%H%M%S`.log

#Ensure we're running with the correct Jenkins version.
#dcos package repo add --index=0 jenkins-aws "${STUB_UNIVERSE_URL}"

#dcos package repo remove jenkins-aws
#export STUB_UNIVERSE_URL='https://universe-converter.mesosphere.com/transform?url=https://infinity-artifacts.s3.amazonaws.com/permanent/jenkins/assets/scale-test-jenkins-2.150.1/stub-universe-jenkins.json'
#dcos package repo add --index=0 jenkins-aws $STUB_UNIVERSE_URL

dcos package repo remove jenkins-mwt
export STUB_UNIVERSE_URL='https://universe-converter.mesosphere.com/transform?url=https://infinity-artifacts.s3.amazonaws.com/permanent/jenkins/assets/jenkins-mwt-suppress-1/stub-universe-jenkins.json'
dcos package repo add --index=0 jenkins-mwt $STUB_UNIVERSE_URL


#cls; DCOS_LOGIN_USERNAME="bootstrapuser" DCOS_LOGIN_PASSWORD="deleteme" PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=30 --scenario=sleep --min=0 --max=1 --batch-size=1" ./test.sh -m scale jenkins |& tee -a $LOGFILE
cls; DCOS_LOGIN_USERNAME="bootstrapuser" DCOS_LOGIN_PASSWORD="deleteme" PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=30 --scenario=sleep --min=1 --max=2 --batch-size=1" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#cls; DCOS_LOGIN_USERNAME="bootstrapuser" DCOS_LOGIN_PASSWORD="deleteme" PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=30 --scenario=sleep --min=1 --max=15 --batch-size=14" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#cls; DCOS_LOGIN_USERNAME="bootstrapuser" DCOS_LOGIN_PASSWORD="deleteme" PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=30 --scenario=sleep --min=15 --max=16 --batch-size=1" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#cls; DCOS_LOGIN_USERNAME="bootstrapuser" DCOS_LOGIN_PASSWORD="deleteme" PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=30 --scenario=sleep --min=1 --max=2 --batch-size=1" ./test.sh -m scale jenkins |& tee -a $LOGFILE
#cls; DCOS_LOGIN_USERNAME="bootstrapuser" DCOS_LOGIN_PASSWORD="deleteme" PYTEST_ARGS="--mom=mom-4 --jobs=5 --work-duration=30 --scenario=sleep --min=2 --max=3 --batch-size=1" ./test.sh -m scale jenkins |& tee -a $LOGFILE
