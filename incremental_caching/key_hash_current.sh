#!/bin/bash

# Determine if an incremental cache supplied in Solano CI session is still appropriate
# http://docs.solanolabs.com/Beta/incremental-caching/

# Exits non-zero if the stored cache hash is no longer appropriate

# If the previous and current cache hashes match, the current one will be removed so only the one generated with the supplied cache is present.
# Due to this behavior, this script should only be called once with the same argument per session.

set -e

CACHE_KEY_PATH=$HOME/cache-keys

# Needs at least one argument
if [ -z "$1" ]; then 
  echo "ERROR: $0 needs an argument identifying the named cache key"
  echo "Usage: $0 <name>"
  exit 1
fi

NAME=$1
HASH_PATH_PATTERN=${CACHE_KEY_PATH}/${NAME}-
HASH_CURRENT_FILE=${CACHE_KEY_PATH}/${NAME}-${TDDIUM_SESSION_ID}

# Was a cache hash already generated?
if [ ! -f $HASH_CURRENT_FILE ]; then
  echo "ERROR: A calculated cache hash was not found for $NAME for this build"
  exit 2
fi

# Fetch current session's hash
HASH_CURRENT=`cat $HASH_CURRENT_FILE`

# Are previous sessions' hash also stored?
HASHES_PREVIOUS_COUNT=`find $CACHE_KEY_PATH -type f | grep -v ^$HASH_CURRENT_FILE | grep -c ^$HASH_PATH_PATTERN`
if [[ "$HASHES_PREVIOUS_COUNT" == "0" ]]; then
  echo "NOTICE: A previous sessions calculated cache hash could not be found"
  exit 101
fi
if [[ "$HASHES_PREVIOUS_COUNT" != "1" ]]; then
  echo "ERROR: More than 1 previous sessions' calculated cache has was found for ${NAME}."
  echo "Deleting all of them except the current session's (${HASH_CURRENT_FILE})"
  find $CACHE_KEY_PATH -type f | grep ^$HASH_PATH_PATTERN | grep -v ^$HASH_CURRENT_FILE | xargs rm
  exit 3
fi

# Fetch previous session's hash
HASH_PREVIOUS_FILE=`find $CACHE_KEY_PATH -type f | grep ^$HASH_PATH_PATTERN | grep -v ^$HASH_CURRENT_FILE`
HASH_PREVIOUS=`cat $HASH_PREVIOUS_FILE`

# Check if the hashes do not match
if [[ "$HASH_CURRENT" != "$HASH_PREVIOUS" ]]; then
  # Since the hashes do not match, delete the previous session's hash file
  rm $HASH_PREVIOUS_FILE
  echo "NOTICE: The calculated hash for $NAME did not match the previous session (${HASH_PREVIOUS_FILE})"
  exit 102
fi

# Since the hashes matched, delete the current session's hash file
rm $HASH_CURRENT_FILE
echo "NOTICE: The calculated hash for $NAME matched the previous session (${HASH_PREVIOUS_FILE})"
echo 0
