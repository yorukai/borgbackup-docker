FROM alpine:3.22

LABEL org.opencontainers.image.source https://github.com/pm-dennis/borgbackup-docker

VOLUME /home/.ssh
VOLUME /etc/ssh

ARG BORG_USER="borgbackup"
ENV BORG_USER=${BORG_USER}

# List of public keys for SSH access
ENV SSH_AUTHORIZED_KEYS=""

RUN apk add --no-cache openssh-server

COPY ./add2chroot.sh /usr/local/bin/add2chroot.sh

RUN chmod +x /usr/local/bin/add2chroot.sh && \
    mkdir -p /chroot/bin /chroot/lib /chroot/lib64 /chroot/usr /chroot/home /chroot/etc/apk && \
    cp -r /etc/apk/repositories /etc/apk/keys /chroot/etc/apk/ && \
    echo "PS1='\[\e[31m\]\u\[\e[0m\] \[\e[33m\]\w\[\e[0m\] \[\e[36m\]>\[\e[0m\] '" > /etc/profile.d/prompt.sh && \
    apk add --root /chroot --initdb borgbackup && \
    /usr/local/bin/add2chroot.sh \
      /bin/ls /usr/bin/tree /bin/cat /bin/chmod /usr/bin/du \
      /bin/dd /bin/rm /bin/cp /bin/touch /bin/mkdir \
      /bin/rmdir /bin/mv /usr/bin/tail /usr/bin/head \
      /bin/grep /bin/stat /bin/df /bin/pwd /bin/ash \
      /usr/bin/md5sum /usr/bin/sha1sum /usr/bin/sha256sum /usr/bin/sha512sum

# Create borgbackup user and group
RUN addgroup -g 1000 -S "$BORG_USER" && \
    adduser -D -u 1000 -G "$BORG_USER" -h /home -s /bin/ash "$BORG_USER" && \
    echo "${BORG_USER}:$(date +%s | sha256sum | base64 | head -c 30)" | chpasswd && \
    chown -R "$BORG_USER:$BORG_USER" /home /chroot/home && \
    cp /etc/passwd /etc/group /chroot/etc/

COPY ./config/chroot/profile ./config/chroot/motd /chroot/etc/
COPY ./config/ssh/sshd_config /etc/ssh/sshd_config
COPY ./entrypoint.sh /entrypoint.sh

WORKDIR /home
EXPOSE 22

ENTRYPOINT ["sh", "/entrypoint.sh"]
