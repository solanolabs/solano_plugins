#!/bin/bash
# Copyright (c) 2016 Solano Labs All Rights Reservced

# Bitbucket.org API v2.0 build status update script

# BB_USERNAME and BB_PASSWORD should be provided using the `solano config:add` cli command:
# http://docs.solanolabs.com/Setup/setting-environment-variables/#via-config-variables
if [ -z "$BB_USERNAME" ]; then
  echo "\$BB_USERNAME needs to be set"
  echo "See http://docs.solanolabs.com/Setup/setting-environment-variables/#via-config-variables"
  exit 1
fi
if [ -z "$BB_PASSWORD" ]; then 
  echo "\$BB_PASSWORD needs to be set"
  echo "See http://docs.solanolabs.com/Setup/setting-environment-variables/#via-config-variables"
  exit 1
fi

REPO_NAME=`basename $TDDIUM_REPO_ROOT`
KEY="SOLANO-CI-${TDDIUM_SESSION_ID}"
CI_URL="https://ci.solanolabs.com/reports/${TDDIUM_SESSION_ID}"
BB_URL="https://api.bitbucket.org/2.0/repositories/${BB_USERNAME}/${REPO_NAME}/commit/${TDDIUM_CURRENT_COMMIT}/statuses/build"

function update_status () {
  echo "Updating bitbucket build status to $1"
  JSON="{\"state\":\"${1}\",\"key\":\"${KEY}\",\"name\":\"${KEY}\",\"url\":\"${CI_URL}\"}"
  echo $JSON
  curl -u "${BB_USERNAME}:${BB_PASSWORD}" -H "Content-Type: application/json" \
    -X POST ${BB_URL} \
    --data ${JSON}
  if [ $? -ne 0 ]; then
    echo "ERROR: Bitbucket status update failed."
    echo "Are the \$BB_USERNAME and \$BB_PASSWORD environment variables correct and valid?"
    exit 1
  fi
}

case $1 in
  "building")
    update_status "INPROGRESS"
    ;;
  "finished")
    case $TDDIUM_BUILD_STATUS in
      "passed")
        update_status "SUCCESSFUL"
        ;;
      "failed")
        update_status "FAILED"
        ;;
      "error")
        update_status "FAILED"
        ;;
      *)
        echo "Unhandled \$TDDIUM_BUILD_STATUS"
        update_status "FAILED"
        exit 4
        ;;
    esac 
    ;;
  *)
    echo "Unhandled comand $1"
    exit 3
    ;;
esac
