#!/bin/bash

set -euo pipefail

export ARCH=linux-amd64
export AWS_NUKE_VERSION=2.15.0.rc.3
export AWS_NUKE_FILE=aws-nuke-v$AWS_NUKE_VERSION-$ARCH
export AWS_NUKE_URL=https://github.com/rebuy-de/aws-nuke/releases/download/v2.15.0-rc.3/$AWS_NUKE_FILE.tar.gz
export AWS_NUKE_EXE=aws-nuke
export AWS_NUKE_CONFIG=config/nuke-config-test.yml
export TIMESTAMP=$(date +%Y-%m-%dT%H:%M%z)

if [ ! "${1:-}" ]; then 
  echo "Specify a subcommand."
  exit 1
fi

case $1 in
  info)
    ./$AWS_NUKE_EXE version
  ;;
  clean)
   [ -f "$AWS_NUKE_EXE" ] && rm $AWS_NUKE_EXE
   [ -d "log" ] && rm -r log 
  ;;
  dryrun)
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG
  ;;
  nuke)
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG --no-dry-run
  ;;
  headless-dryrun)
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG --force > log/aws-nuke-"$TIMESTAMP".log 2>&1
  ;;
  headless-nuke)
    ./$AWS_NUKE_EXE --config $AWS_NUKE_CONFIG --force --no-dry-run > log/aws-nuke-"$TIMESTAMP".log 2>&1
  ;;
  setup)
    curl -L $AWS_NUKE_URL > $AWS_NUKE_FILE.tar.gz 
    tar xvzf $AWS_NUKE_FILE.tar.gz
    mv $AWS_NUKE_FILE $AWS_NUKE_EXE 
    chmod +x $AWS_NUKE_EXE
    [ -d "log" ] || mkdir log
    rm $AWS_NUKE_FILE.tar.gz
  ;;
  *)
    echo "$1 is not a valid command"
  ;;
esac
