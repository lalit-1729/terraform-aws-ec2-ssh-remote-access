cat << EOF >> ~/.ssh/config

Host ${HOSTNAME}
    HostName ${HOSTNAME}
    User ${USER}
    identityFile ${identityFile}
EOF