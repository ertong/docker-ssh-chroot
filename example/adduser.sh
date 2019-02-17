#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR

echo "User name:"
read NAME
echo "User ID:"
read ID
echo "User pass:"
read PASS

PASS=$(python3 -c 'import crypt; import sys; print(crypt.crypt(sys.argv[1]))' $PASS)

echo $NAME:$ID:$PASS >> users
