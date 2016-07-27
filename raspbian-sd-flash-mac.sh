#!/usr/bin/env bash

SCRIPT_HOME=${SCRIPT_HOME:-$(dirname $0)}

function err {
  echo -e "\033[91m[ERROR] $1\033[0m"
}

function info {
  echo -e "\033[92m[INFO] $1\033[0m"
}

function alert {
  echo -e "\033[93m[ALERT] $1\033[0m"
}

function assert_root {
  if [[ $EUID -ne 0 ]]; then
     err "This script must be run as root"
     exit 1
  fi
}

function download_raspbian_img {
  . ${SCRIPT_HOME}/_download_img.sh raspbian_latest http://downloads.raspberrypi.org/raspbian_latest
}

function look_for_sd_card_id {
  for t in Windows_FAT_32 Linux; do
    SD_ID=`diskutil list | grep ${t} | awk -F' ' '{print $6}'`
    if [ -z "${SD_ID}" ]; then
      SD_ID=`diskutil list | grep ${t} | awk -F' ' '{print $5}'`
      if [ -n "${SD_ID}" ]; then
        break
      fi
    else
      break
    fi
  done

  if [ -z "${SD_ID}" ]; then
    err "SD card is missing"
    exit 1
  fi

  SD_ID_END_INDEX=`expr ${#SD_ID} - 2`
  SD_ID=${SD_ID:0:${SD_ID_END_INDEX}}
}

function confirm_dd {
  info "I've found the following SD card."
  diskutil list "/dev/${SD_ID}"
  alert "I'm going to flash Raspbian OS to the card, are you sure? (y/N)"
  read ANSWER
  if [ -z ${ANSWER} ]; then
    ANSWER=N
  fi
  if [ "${ANSWER}" == "y" ] || [ "${ANSWER}" == "Y" ]; then
    info "Got it. Now working..."
  else
    err "Oops. Quit the operation."
    exit 1
  fi
}

function unmount_sd {
  RET=""
  while [ "${RET}" != "0" ]; do
    RET=`diskutil unmountDisk /dev/${SD_ID}`
    RET="$?"
  done
}

function perform_dd {
  unmount_sd
  info "Starting dd...."
  dd bs=1m if=${IMG_DIR}/raspbian_latest.img of=/dev/r${SD_ID}
  sleep 1
  unmount_sd
}

assert_root
download_raspbian_img
look_for_sd_card_id
confirm_dd
perform_dd

info "OK"
