#!/bin/sh
# vpnc-pre_setup.sh
# Install and configure vpnc.
# Requires the presence of certain environment variables:
#   $VPNC_GATEWAY
#   $VPNC_ID
#   $VPNC_SECRET
#   $VPNC_USERNAME
#   $VPNC_PASSWORD

set -e # Exit on error

# Ensure all of the necessary environment variables set
required_vars="VPNC_GATEWAY VPNC_ID VPNC_SECRET VPNC_USERNAME VPNC_PASSWORD"
vars_set=true
for var in $required_vars; do
  eval val=\""\$$var"\"
  if [ "$val" == "" ]; then
    echo "ERROR: $var is not set"
    vars_set=false
  fi
done
if [ "$vars_set" == "false" ]; then
  echo "ERROR: Not all required environemnt variables are set"
  echo 'See: http://docs.solanolabs.com/Setup/setting-environment-variables/#via-config-variables'
  echo 'Please use `solano config:add <scope> <key> <value>` to set sensitive values'
  exit 1
fi

# Create vpnc configuration file from environment variables
cat > vpnc.conf <<EOF
IPSec gateway ${VPNC_GATEWAY}
IPSec ID ${VPNC_ID}
IPSec secret ${VPNC_SECRET}
Xauth username ${VPNC_USERNAME}
Xauth password ${VPNC_PASSWORD}
DPD idle timeout (our side) 0
EOF

# Install vpnc
sudo apt-get -f -y install && sudo apt-get -y install vpnc
