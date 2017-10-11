#! /bin/sh

PROFILE="default"
BUCKET="thomasphorton.com"

# Get command line parameters
while [ "$1" != "" ]; do
  case $1 in
    -p | --profile )
    shift
    PROFILE=$1
    ;;

    -b | --bucket-name )
    shift
    BUCKET=$1
    ;;

  esac
  shift
done

aws s3 sync ./src s3://$BUCKET --profile $PROFILE --delete
