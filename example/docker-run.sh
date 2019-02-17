#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR


docker stop ssh-chroot
docker rm ssh-chroot

MOUNT=""

while read -r line
do
    NAME=$(echo $line | cut -d: -f 1)
    echo "User: $NAME"
    mkdir -p $DIR/home/$NAME
    MOUNT="$MOUNT -v $DIR/home/$NAME:/home/$NAME/home"
done < "$DIR/users"

docker run -d -p 2222:22 \
 $MOUNT \
 -v $DIR/users:/users \
 --name ssh-chroot \
 ertong/ssh-chroot