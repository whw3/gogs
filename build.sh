#!/bin/bash
mkdir -p /app/gogs/
cat >/app/gogs/gogs <<'END'
#!/bin/sh
ssh -p 10022 -o StrictHostKeyChecking=no git@127.0.0.1 \
"SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
END
chmod 755 /app/gogs/gogs

mkdir -p /srv/gogs/data/
mkdir -p /srv/gogs/data/git/.ssh
if [[ "$(getent passwd git)" = "" ]]; then
    useradd -d /srv/gogs/data -M -u 65522 git
    groupadd -g 65522 git
else
    echo "User git already exists"
fi
GIT_UID=$(id -u git)
GIT_HOME=$(eval echo "~git")
cd  $GIT_HOME
if [[ ! -L .ssh ]]; then
    if [[ -d .ssh ]]; then
        echo "User git already exists and has a pre-existing configuration for SSH access"
        echo "Unable to proceed. Script Terminated."
        exit 2
    fi
    ln -s /srv/gogs/data/git/.ssh .ssh
fi
cd /srv/gogs/data/git/.ssh
if [[  ! -f id_rsa ]]; then
    ssh-keygen -t rsa -b 4096 \
     -O no-port-forwarding \
     -O no-X11-forwarding \
     -O no-agent-forwarding \
     -O no-pty \
     -C "git@$HOSTNAME" \
     -f id_rsa
     
    sed -i '1s;^;no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ;' id_rsa.pub
    if [[ -f authorized_keys ]]; then
        cat id_rsa.pub >> authorized_keys
    else
        cat id_rsa.pub > authorized_keys
    fi
fi
chmod 0600 id_rsa authorized_keys
chown -R git: /srv/gogs/data/
chmod o-rwx -R /srv/gogs/data/

cd /srv/docker/
[[ -d gogs ]] && rm -rf gogs
git clone https://github.com/gogits/gogs.git
cd gogs
mv Dockerfile Dockerfile.x64
cp Dockerfile.rpi Dockerfile
sed -i 's/^adduser -H/adduser -u '$GIT_UID' -H/' docker/build.sh
docker build -t gogs .
