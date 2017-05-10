#!/bin/bash

# Calculate hash of specific files and directories to determine if
# incremental cache supplied during Solano CI session is current
# http://docs.solanolabs.com/Beta/incremental-caching/

CACHE_KEY_PATH=$HOME/cache-keys

# There must be at least two arguments
if [ $# -lt 2 ]; then
  # Ensure output is unique so calculated hash does not match a previous Solano CI session's hash
  echo "ERROR: $0 must have at least two arguments!"
  date +%s | md5sum | cut -c1-32
  exit 1
fi

# Calculate the cache hash
NAME=$1   # The first parameter is an identifier for the cache-key
shift     # Remove the first parameter
HASH=$(
  set -o errexit -o pipefail
  find "$@" -type f -exec md5sum {} \; | sort -k 2 | md5sum | cut -c1-32
)

# If calculating the hash exited non-zero (likely due to a non-existant path argument),
# ensure output is unique so calculated hash does not match a previous Solano CI session's hash
if [[ "$?" != "0" ]]; then
  echo "ERROR: calculating the hash exited non-zero. Are all supplied path arguments present?"
  date +%s | md5sum | cut -c1-32
  exit 2
fi

# Return the calculated hash and also write it to file
mkdir -p $CACHE_KEY_PATH
echo $HASH | tee ${CACHE_KEY_PATH}/${NAME}-current
