# Update BitBucket build status during Solano CI Session

The ``update_bb_status.sh`` script will send build status updates to BitBucket's v2.0 API.
A ``building`` argument triggers a ``INPROGRESS`` notification, while a ``finished`` argument
will trigger a ``SUCCESSFUL`` or ``FAILED`` notification depending on if all of the tests have passed.

##### Configuration to merge into ``solano.yml``:

```
# The update_bb_status.sh script expects $BB_USERNAME and $BB_PASSWORD environment variables to be set.
# For sensitive environment variables, use `solano config:add repo <key> <value>` from the cli
# See: http://docs.solanolabs.com/Setup/setting-environment-variables/#via-config-variables
# environment:
#   'BB_USERNAME': '<set-with-cli>'
#   'BB_PASSWORD': '<set-with-cli>'

# Include status notifications at the beginning of the `pre_setup` setup hook and the end of the `post_build` setup hook.
# See http://docs.solanolabs.com/Setup/setup-hooks/
hooks:
  pre_setup: ./update_bb_status.sh building
  post_build: ./update_bb_status.sh finished
```

