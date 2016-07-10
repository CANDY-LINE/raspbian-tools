#!/usr/bin/env bash

# Wait for RPi to respond to SSH request

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
    pi@raspberrypi.local "hostnamectl"
  expect {
      "password:" {
        send "raspberry\r"
        interact
      }
      "ssh:" {
        exit 1
      }
  }' 2>&1 /dev/null)
  return "$?"
}

MAX=1
COUNTER=0
echo -n "Testing SSH to pi@raspberrypi.local "
while [ expect_ssh != "0" ] && [ ${COUNTER} -lt ${MAX} ];
do
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
  info "SSH is ready. Run 'ssh pi@raspberrypi.local'"
fi
