#!/usr/bin/env bash

# Wait for RPi to respond to SSH request

SSH_USER=${SSH_USER:-pi}
SSH_PASSWORD=${SSH_PASSWORD:-raspberry}
RPI_HOST=${RPI_HOST:-raspberrypi.local}

function err {
  echo -e "\033[91m[ERROR] $1\033[0m"
}

function info {
  echo -e "\033[92m[INFO] $1\033[0m"
}

function expect_ssh {
  EXPECT=$(expect -c '
  spawn ssh \
    -o ConnectTimeout=1 \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    ${SSH_USER}@${RPI_HOST} "hostnamectl"
  expect {
      "password:" {
        send "${SSH_PASSWORD}\r"
        interact
      }
      "ssh:" {
        exit 1
      }
  }' 2>&1 /dev/null)
  RET="$?"
}

MAX=100
COUNTER=0
echo -n "Testing SSH to pi@raspberrypi.local "
while [ ${COUNTER} -lt ${MAX} ];
do
    expect_ssh
    if [ ${RET} == "0" ]; then
      break
    fi
    sleep 1
    let COUNTER=COUNTER+1
    echo -n "."
done
echo
if [ ${COUNTER} -ge ${MAX} ];
then
  err "TIMEOUT"
  err "Make sure your raspberrypi is connected to the network"
else
  info "OK"
  info "SSH is ready. Run 'ssh ${SSH_USER}@${RPI_HOST}'"
fi
