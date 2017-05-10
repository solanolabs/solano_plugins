#!/bin/bash -e

# Determine if an incremental cache supplied in Solano CI session is still appropriate
# http://docs.solanolabs.com/Beta/incremental-caching/

# Exits non-zero if the stored cache hash is no longer appropriate

# If the previously generated and current cache hashes do not match, the current hash file will replace the previous on.
# Due to this behavior, this script should only be called once with the same argument per session.

CACHE_KEY_PATH=$HOME/cache-keys

# Needs at least one argument
if [ -z "$1" ]; then
  echo "ERROR: $0 needs an argument identifying the named cache key"
  echo "Usage: $0 <name>"
  exit 1
fi

NAME=$1
HASH_PREVIOUS_FILE=${CACHE_KEY_PATH}/${NAME}-previous
HASH_CURRENT_FILE=${CACHE_KEY_PATH}/${NAME}-current

# Was a cache hash already generated?
if [ ! -f $HASH_CURRENT_FILE ]; then
  echo "ERROR: A calculated cache hash was not found for '$NAME'"
  exit 2
fi

# Was a previous cache supplied?
if [ ! -f $HASH_PREVIOUS_FILE ]; then
  echo "NOTICE: A previously generated calculated cache has was not found for '$NAME'"
  mv $HASH_CURRENT_FILE $HASH_PREVIOUS_FILE
  exit 100
fi

# Fetch current session's hash
HASH_CURRENT=`cat $HASH_CURRENT_FILE`
HASH_PREVIOUS=`cat $HASH_PREVIOUS_FILE`

# Check if the hashes do not match
if [[ "$HASH_CURRENT" != "$HASH_PREVIOUS" ]]; then
  echo "NOTICE: The calculated hash for '$NAME' did not match the previously generated hash"
  mv $HASH_CURRENT_FILE $HASH_PREVIOUS_FILE
  exit 101
fi

# Since the hashes matched, delete the current session's hash file
rm $HASH_CURRENT_FILE
echo "NOTICE: The calculated hash for '$NAME' matched the previously generated hash"
exit 0
