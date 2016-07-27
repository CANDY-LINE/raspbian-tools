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

function resolve_host {
  ping -c 5 ${RPI_HOST} > /dev/null 2>&1
  RET="$?"
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
      eof
  }' 2>&1 /dev/null)
  RET="$?"
}

MAX=100
COUNTER=0

info "Looking for ${RPI_HOST}..."
while [ ${COUNTER} -lt ${MAX} ];
do
  resolve_host
  if [ "${RET}" == "0" ]; then
    break
  fi
  let COUNTER=COUNTER+1
  echo -n "."
done
if [ ${COUNTER} -ge 1 ];
then
  echo
elif [ ${COUNTER} -ge ${MAX} ];
then
  err "TIMEOUT"
  err "Make sure your raspberrypi is connected to the network"
  exit 1
fi

COUNTER=0
info "Testing SSH to ${SSH_USER}@${RPI_HOST} "
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
info
if [ ${COUNTER} -ge ${MAX} ];
then
  err "TIMEOUT"
  err "Make sure your raspberrypi is connected to the network"
  exit 1
else
  info "OK"
  info "SSH is ready. Run 'ssh ${SSH_USER}@${RPI_HOST}'"
fi
