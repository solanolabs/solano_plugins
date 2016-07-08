# Connecting with VPNC

To use ``vpnc`` to connect to external VPNs during builds, please
reference this README and the ``vpnc-pre_setup.sh`` script.

##### Configuration to merge into ``solano.yml``:

```
system:
  docker: true  # Start workers in privileged mode and allow sudo

# For sensitive environment variables, use `solano config:add repo <key> <value>` from the cli
# See: http://docs.solanolabs.com/Setup/setting-environment-variables/#via-config-variables
# environment:
#   'VPNC_GATEWAY': '<set-with-cli>'
#   'VPNC_ID': '<set-with-cli>'
#   'VPNC_SECRET': '<set-with-cli>'
#   'VPNC_USERNAME': '<set-with-cli>'
#   'VPNC_PASSWORD': '<set-with-cli>'

hooks:
  pre_setup: ./vpnc-pre_setup.sh  # Install and configure vpnc
  worker_setup: sudo vpnc-connect --debug 3 --local-port 0 ./vpnc.conf  # Connect with vpnc
```

