#!/bin/bash

prepare_user()
{
USER=$1
ID=$2
PASSC=$3
CDIR=$USER

mkdir -p /home/$CDIR
mkdir -p /home/$CDIR/dev/
cd /home/$CDIR/dev/
mknod -m 666 null c 1 3
mknod -m 666 tty c 5 0
mknod -m 666 zero c 1 5
mknod -m 666 random c 1 8

chown root:root /home/$CDIR
chmod 0755 /home/$CDIR
ls -ld /home/$CDIR

mkdir -p /home/$CDIR/bin
mkdir -p /home/$CDIR/lib64/
mkdir -p /home/$CDIR/lib/x86_64-linux-gnu

useradd $USER -u $ID -s /bin/bash -d /home

echo "$USER:$PASSC" | chpasswd -e
mkdir /home/$CDIR/etc
cat /etc/passwd | grep -E "($USER):" > /home/$CDIR/etc/passwd
cat /etc/group | grep -E "($USER):" > /home/$CDIR/etc/group


echo "Match User $USER" >> /etc/ssh/sshd_config
echo "ChrootDirectory /home/$CDIR" >> /etc/ssh/sshd_config

mkdir -p /home/$CDIR/home
chown -R $USER:$USER /home/$CDIR/home
chmod -R 0700 /home/$CDIR/home

cp -vf /lib/x86_64-linux-gnu/{libnss_compat.so.2,libnsl.so.1,libnss_nis.so.2,libnss_files.so.2} /home/$CDIR/lib/x86_64-linux-gnu

while read -r line
do
    echo "C: $line"

    line=$(which $line)
    cp -v $line /home/$CDIR/bin/
    /l2chroot.sh /home/$CDIR $line >/dev/null
done < "/cmds"

echo "passwd: files" > /home/$CDIR/etc/nsswitch.conf
echo "group: files" >> /home/$CDIR/etc/nsswitch.conf
}

if [ ! -f /etc/ssh/keys/ssh_host_rsa_key ]; then
  ssh-keygen -q -t rsa -f /etc/ssh/keys/ssh_host_rsa_key -C ""  -N ""
  #ssh-keygen -q -t dsa -f /etc/ssh/keys/ssh_host_dsa_key -C ""  -N ""
  ssh-keygen -q -t ecdsa -f /etc/ssh/keys/ssh_host_ecdsa_key -C ""  -N ""
  ssh-keygen -q -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key -C ""  -N ""
fi


while read -r line
do
    echo "User: $line"
    NAME=$(echo $line | cut -d: -f 1)
    ID=$(echo $line | cut -d: -f 2)
    PASSC=$(echo $line | cut -d: -f 3)
    prepare_user $NAME $ID $PASSC
    #prepare_user usr "$(python3 -c 'import crypt; import sys; print(crypt.crypt(sys.argv[1]))' $PASS)"
done < "/users"


echo Exec sshd
exec /usr/sbin/sshd -D