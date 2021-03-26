#!/bin/bash

set -euo pipefail

### Configuration

export AWS_NUKE_EXE=./bin/aws-nuke
export AWS_NUKE_WAIT_SECONDS=3 # aws-nuke minimum is 3 seconds
export AWS_NUKE_MAX_RETRIES=10

### Functions

function specify_version () {
  OS_ID="$(uname -a)"
  MACOS_ALIAS=Darwin
  if [[ $OS_ID == *"$MACOS_ALIAS"* ]]; then
    export OS=darwin
  else
    export OS=linux
  fi

  # On GitHub, the version numbers in URL and filename are NOT consistent
  export AWS_NUKE_VERSION=2.15.0.rc.4
  export ARCH=amd64
  export AWS_NUKE_FILE=aws-nuke-v$AWS_NUKE_VERSION-$OS-$ARCH
  export AWS_NUKE_URL=https://github.com/rebuy-de/aws-nuke/releases/download/v2.15.0-rc.4/$AWS_NUKE_FILE.tar.gz
}

function require_config () {
  if [ ! "${AWS_NUKE_CONFIG:-}" ]; then 
    echo "Specify a configuration file."
    exit 1
  fi
}

function set_timestamp () {
  if [ ! "${TIMESTAMP:-}" ]; then
    TIMESTAMP=$(date +%Y-%m-%dT%H:%M%z) 
    export TIMESTAMP
  fi
}

### Main

if [ ! "${1:-}" ]; then 
  echo "Specify a subcommand."
  exit 1
fi

if [ "${2:-}" ]; then 
  export AWS_NUKE_CONFIG=./config/aws-nuke/"$2".yml
fi

if [ "${3:-}" ]; then 
  export TIMESTAMP=$3
fi

case $1 in
  info)
    ./$AWS_NUKE_EXE version
  ;;
  clean)
   [ -d "bin" ] && rm -r bin 
   [ -d "log" ] && rm -r log 
  ;;
  dryrun)
    require_config
    ./$AWS_NUKE_EXE --config "$AWS_NUKE_CONFIG"
  ;;
  nuke)
    require_config
    ./$AWS_NUKE_EXE --config "$AWS_NUKE_CONFIG" --no-dry-run
  ;;
  headless:dryrun)
    require_config
    set_timestamp
    export TIMESTAMP=test0001
    ./$AWS_NUKE_EXE --config "$AWS_NUKE_CONFIG" --force --force-sleep $AWS_NUKE_WAIT_SECONDS --max-wait-retries $AWS_NUKE_MAX_RETRIES > log/aws-nuke-"$TIMESTAMP"-full.log
  ;;
  headless:nuke)
    require_config
    set_timestamp
    ./$AWS_NUKE_EXE --config "$AWS_NUKE_CONFIG" --force --force-sleep $AWS_NUKE_WAIT_SECONDS --max-wait-retries $AWS_NUKE_MAX_RETRIES --no-dry-run > log/aws-nuke-"$TIMESTAMP"-full.log
  ;;
  setup)
    specify_version
    [ -d "bin" ] || mkdir bin
    if [ ! -x "$AWS_NUKE_EXE" ]; then 
      curl -L $AWS_NUKE_URL > $AWS_NUKE_FILE.tar.gz 
      tar xvzf $AWS_NUKE_FILE.tar.gz
      mv $AWS_NUKE_FILE $AWS_NUKE_EXE 
      chmod +x $AWS_NUKE_EXE
      rm $AWS_NUKE_FILE.tar.gz
    fi
    [ -d "log" ] || mkdir log
  ;;
  timestamp)
    set_timestamp
    echo "$TIMESTAMP"
  ;;
  *)
    echo "$1 is not a valid command"
  ;;
esac
