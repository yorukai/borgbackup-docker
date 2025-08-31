#!/usr/bin/env sh

# Check if the SSH authorized_keys file exists
if [ ! -f ".ssh/authorized_keys" ]; then
  # Check if the .ssh directory exists, if not create it
  if [ ! -d ".ssh" ]; then
    mkdir -p ".ssh"
    chmod 700 .ssh
  fi

  echo "$SSH_AUTHORIZED_KEYS" > .ssh/authorized_keys
  chmod 600 .ssh/authorized_keys
  chown -R "$BORG_USER:$BORG_USER" .ssh
fi

echo
echo "Starting SSH/BorgBackup server..."
echo
echo -e "BorgBackup user: \033[0;33m${BORG_USER}\033[0m"
echo -e "BorgBackup repositories will be stored in: \033[0;33m/chroot/home\033[0m"
echo

ssh-keygen -A
/usr/sbin/sshd -D -e
