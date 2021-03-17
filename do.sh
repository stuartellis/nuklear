#!/bin/bash

set -euo pipefail

export ARCH=linux-amd64
export AWS_NUKE_VERSION=2.15.0.rc.3
export AWS_NUKE_FILE=aws-nuke-v$AWS_NUKE_VERSION-$ARCH
export AWS_NUKE_URL=https://github.com/rebuy-de/aws-nuke/releases/download/v2.15.0-rc.3/$AWS_NUKE_FILE.tar.gz
export AWS_NUKE_EXE=./bin/aws-nuke
export AWS_NUKE_WAIT_SECONDS=1
export AWS_NUKE_MAX_RETRIES=10
export TIMESTAMP=$(date +%Y-%m-%dT%H:%M%z)

if [ ! "${1:-}" ]; then 
  echo "Specify a subcommand."
  exit 1
fi

function require_config  () {
  if [ ! "${2:-}" ]; then 
    echo "Specify a configuration file."
    exit 1
  fi
  export AWS_NUKE_CONFIG=config/$2
}

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
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG
  ;;
  nuke)
    require_config
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG --no-dry-run
  ;;
  headless-dryrun)
    require_config
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG --force --force-sleep $AWS_NUKE_WAIT_SECONDS --max-wait-retries $AWS_NUKE_MAX_RETRIES > log/aws-nuke-"$TIMESTAMP"-full.log 2>&1
  ;;
  headless-nuke)
    require_config
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG --force --force-sleep $AWS_NUKE_WAIT_SECONDS --max-wait-retries $AWS_NUKE_MAX_RETRIES --no-dry-run > log/aws-nuke-"$TIMESTAMP"-full.log 2>&1
  ;;
  setup)
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
  *)
    echo "$1 is not a valid command"
  ;;
esac
