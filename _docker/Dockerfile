FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y openssh-server rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && rm -rf /etc/ssh/ssh_host_*.* \
    && rm -rf /etc/ssh/ssh_host_* \
    && mkdir -p /etc/ssh/keys \
    && echo "HostKey /etc/ssh/keys/ssh_host_rsa_key" >> /etc/ssh/sshd_config \
    && echo "HostKey /etc/ssh/keys/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config \
    && echo "HostKey /etc/ssh/keys/ssh_host_ed25519_key" >> /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ADD l2chroot.sh /l2chroot.sh
ADD cmds /cmds
ADD run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE 22
CMD ["/run.sh"]