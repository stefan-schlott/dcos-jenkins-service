#!/bin/bash
# Launch script for the docker container

function help() {
  echo "Please provide the following environment variables:"
  echo " - MARATHON_UPDATE_INTERVAL : How often to trigger an update (seconds)"
  echo " - MARATHON_UPDATE_URL      : The URL where to send update requests"
  echo " - MARATHON_UPDATE_COUNT    : How many apps to update"
  echo ""
  echo "The following are optional:"
  echo " - MARATHON_UPDATE_RATE     : How many requests per second to perform"
  echo " - MARATHON_UPDATE_BURST    : How many requests to send in parallel"
  echo " - DCOS_AUTH_TOKEN          : The authentication DC/OS token to use"
}

# Require a configured environment
[ -z "$MARATHON_UPDATE_INTERVAL" ] && help && exit 1
[ -z "$MARATHON_UPDATE_URL" ] && help && exit 1
[ -z "$MARATHON_UPDATE_COUNT" ] && help && exit 1

# Prepare command-line
CMDLINE="/usr/bin/marathon-update-apps"
[ ! -z "$MARATHON_UPDATE_RATE" ] && CMDLINE="$CMDLINE --rate $MARATHON_UPDATE_RATE"
[ ! -z "$MARATHON_UPDATE_BURST" ] && CMDLINE="$CMDLINE --burst $MARATHON_UPDATE_BURST"
[ ! -z "$DCOS_AUTH_TOKEN" ] && CMDLINE="$CMDLINE --auth $DCOS_AUTH_TOKEN"
CMDLINE="$CMDLINE $MARATHON_UPDATE_COUNT $MARATHON_UPDATE_URL"

# Enter infinite loop
while true; do
  echo "Executing $CMDLINE ..."
  eval $CMDLINE
  echo "Sleeping for $MARATHON_UPDATE_INTERVAL ..."
  sleep $MARATHON_UPDATE_INTERVAL
done
