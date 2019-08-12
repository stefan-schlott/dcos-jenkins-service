#!/bin/bash
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Basic cluster settings, change as needed.
export DCOS_LOGIN_USERNAME=bootstrapuser;
export DCOS_LOGIN_PASSWORD=deleteme;
export CLUSTER_URL=$(dcos config show core.dcos_url);

create_service_accounts() {
    dcos security org service-accounts keypair dcos-monitoring-private-key.pem dcos-monitoring-public-key.pem
    dcos security org service-accounts create -p dcos-monitoring-public-key.pem -d "dcos-monitoring service account" dcos-monitoring-principal
    dcos security secrets create-sa-secret --strict dcos-monitoring-private-key.pem dcos-monitoring-principal dcos-monitoring/service-private-key
}

assign_service_permissions() {
    dcos security org users grant dcos-monitoring-principal dcos:adminrouter:ops:ca:rw full
    dcos security org users grant dcos-monitoring-principal dcos:adminrouter:ops:ca:ro full
    dcos security org users grant dcos-monitoring-principal dcos:mesos:agent:framework:role:slave_public read
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:framework:role:dcos-monitoring-role create
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:framework:role:slave_public read
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:framework:role:slave_public/dcos-monitoring-role read
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:framework:role:slave_public/dcos-monitoring-role create
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:reservation:principal:dcos-monitoring-principal delete
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:reservation:role:dcos-monitoring-role create
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:reservation:role:slave_public/dcos-monitoring-role create
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:task:user:nobody create
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:volume:principal:dcos-monitoring-principal delete
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:volume:role:dcos-monitoring-role create
    dcos security org users grant dcos-monitoring-principal dcos:mesos:master:volume:role:slave_public/dcos-monitoring-role create
    dcos security org users grant dcos-monitoring-principal dcos:secrets:default:/dcos-monitoring/\* full
    dcos security org users grant dcos-monitoring-principal dcos:secrets:list:default:/dcos-monitoring read
}

install_monitoring_service() {
cat >$DIR/dcos-monitoring-options.json <<EOF
{
  "service": {
    "service_account": "dcos-monitoring-principal",
    "service_account_secret": "dcos-monitoring/service-private-key"
  }
}
EOF

	dcos package install dcos-monitoring --options=$DIR/dcos-monitoring-options.json --yes

}

create_service_accounts
assign_service_permissions
install_monitoring_service
