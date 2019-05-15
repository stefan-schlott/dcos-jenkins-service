#!/bin/bash

set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Basic cluster settings, change as needed.
export DCOS_LOGIN_USERNAME=bootstrapuser;
export DCOS_LOGIN_PASSWORD=deleteme;
export CLUSTER_URL=$(dcos config show core.dcos_url);

export JENKINS_STUB_URL='https://universe-converter.mesosphere.com/transform?url=https://infinity-artifacts.s3.amazonaws.com/permanent/jenkins/assets/scale-test-jenkins-2.150.1/stub-universe-jenkins.json';
export EDGELB_STUB_URL='https://downloads.mesosphere.com/edgelb/v1.3.1/assets/stub-universe-edgelb.json';
export EDGELB_POOL_STUB_URL='https://downloads.mesosphere.com/edgelb-pool/v1.3.1/assets/stub-universe-edgelb-pool.json';

# Find security of the cluster
SECURITY_MODE=`curl -k -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/dcos-metadata/bootstrap-config.json | jq .security | tr -d \"`

install_mom()
{
    MOM_APP=marathon-1-8-${SECURITY_MODE}-mom-4.json
    
    # Add docker secret for pulling MoM-EE
    dcos package install dcos-enterprise-cli --yes
    dcos security secrets create -f docker/config.json docker-credentials

    echo "Strict cluster detected, setting up security credentials!"

    # auth for marathon to run as root and mom ees to run
    dcos security org service-accounts keypair mom-private-key.pem mom-public-key.pem
    dcos security org service-accounts create -p mom-public-key.pem -d "Marathon-EE service account" marathon_user_ee

    curl -L -X PUT -k -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:superuser/users/marathon_user_ee/full
    curl -L -H 'Content-Type: application/json' -X PUT -k -H "Authorization: token=$(dcos config show core.dcos_acs_token)" -d '{"description": "dcos:mesos:master:task:user:root"}' $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:mesos:master:task:user:root
    curl -L -X PUT -k -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $(dcos config show core.dcos_url)/acs/api/v1/acls/dcos:mesos:master:task:user:root/users/dcos_marathon/create

    dcos security secrets create-sa-secret --strict mom-private-key.pem marathon_user_ee service-credentials

    echo "Installing MoM!"
    dcos marathon app add $MOM_APP
    echo "Done installing MoM!"
}

configure_jenkins()
{
    # Version of Jenkins deployed for MWT
    dcos package repo add --index=0 jenkins-aws "${JENKINS_STUB_URL}";
}

install_edgelb()
{
    dcos package repo add --index=0 edgelb  "${EDGELB_STUB_URL}"
    
    #Create service accounts
    dcos security org service-accounts keypair edge-lb-private-key.pem edge-lb-public-key.pem
    dcos security org service-accounts create -p edge-lb-public-key.pem -d "Edge-LB service account" edge-lb-principal
    dcos security org service-accounts show edge-lb-principal
    
    if [ "$SECURITY_MODE" = "strict" ]; then
        IS_STRICT="--strict "
    else
        IS_STRICT=""
    fi

    dcos security secrets create-sa-secret ${IS_STRICT} edge-lb-private-key.pem edge-lb-principal dcos-edgelb/edge-lb-secret
    dcos security secrets create-sa-secret edge-lb-private-key.pem edge-lb-principal dcos-edgelb/edge-lb-secret
    #Verification
    dcos security secrets list /

	# Debug version, grant superusers
    #dcos security org groups add_user superusers edge-lb-principal
	
	dcos security org users grant edge-lb-principal dcos:adminrouter:service:marathon full
	dcos security org users grant edge-lb-principal dcos:adminrouter:package full
	dcos security org users grant edge-lb-principal dcos:adminrouter:service:edgelb full
	dcos security org users grant edge-lb-principal dcos:service:marathon:marathon:services:/dcos-edgelb full
	dcos security org users grant edge-lb-principal dcos:mesos:master:endpoint:path:/api/v1 full
	dcos security org users grant edge-lb-principal dcos:mesos:master:endpoint:path:/api/v1/scheduler full
	dcos security org users grant edge-lb-principal dcos:mesos:master:framework:principal:edge-lb-principal full
	dcos security org users grant edge-lb-principal dcos:mesos:master:framework:role full
	dcos security org users grant edge-lb-principal dcos:mesos:master:reservation:principal:edge-lb-principal full
	dcos security org users grant edge-lb-principal dcos:mesos:master:reservation:role full
	dcos security org users grant edge-lb-principal dcos:mesos:master:volume:principal:edge-lb-principal full
	dcos security org users grant edge-lb-principal dcos:mesos:master:volume:role full
	dcos security org users grant edge-lb-principal dcos:mesos:master:task:user:root full
	dcos security org users grant edge-lb-principal dcos:mesos:master:task:app_id full
	
cat >$DIR/edge-lb-options.json <<EOF
{
  "service": {
    "secretName": "dcos-edgelb/edge-lb-secret",
    "principal": "edge-lb-principal",
    "mesosProtocol": "https"
  }
}
EOF

	dcos package install --options=$DIR/edge-lb-options.json edgelb --yes
	until dcos edgelb ping; do sleep 1; done

	echo "EdgeLB installed!"
}

install_edgelb_jenkins_pools()
{
    dcos package repo add --index=0 edgelb-pool  "${EDGELB_POOL_STUB_URL}"

cat >$DIR/jenkins-pool-configuration.json <<EOF
{
  "apiVersion": "V2",
  "name": "jenkins-pool",
  "count": 1,
  "haproxy": {
    "frontends": [
      {
        "bindPort": 80,
        "protocol": "HTTP",
        "linkBackend": {
          "map": [
            {
              "pathBeg": "/jenkins1",
              "backend": "backend-jenkins1"
            },
            {
              "pathBeg": "/jenkins2",
              "backend": "backend-jenkins2"
            }
          ]
        }
      }
    ],
    "backends": [
      {
        "name": "backend-jenkins1",
        "protocol": "HTTP",
        "services": [
          {
            "frameworkName": "mom-4",
            "taskName": "jenkins1"
          }
        ]
      },
      {
        "name": "backend-jenkins2",
        "protocol": "HTTP",
        "services": [
          {
            "frameworkName": "mom-4",
            "taskName": "jenkins2"
          }
        ]
      }
    ]
  }
}
EOF

	dcos security org users grant edge-lb-principal dcos:adminrouter:service:dcos-edgelb/pools/jenkins-pool full

	# Create jenkins pool	
	dcos edgelb create $DIR/jenkins-pool-configuration.json
	
	# Verify
	dcos edgelb endpoints jenkins-pool
}

install_mom
configure_jenkins
install_edgelb
install_edgelb_jenkins_pools

