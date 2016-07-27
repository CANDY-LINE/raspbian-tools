#!/usr/bin/env bash

SCRIPT_HOME=${SCRIPT_HOME:-$(dirname $0)}
IMG_DIR=${SCRIPT_HOME}/img
LOCAL_FILE_NAME=${LOCAL_FILE_NAME:-$1}
DOWNLOAD_URL=${DOWNLOAD_URL:-$2}
UNZIP_DIR=${3:-${IMG_DIR}}

function assert_args {
  if [ -z ${LOCAL_FILE_NAME} ]; then
    echo "LOCAL_FILE_NAME is required"
  fi
  if [ -z ${DOWNLOAD_URL} ]; then
    echo "DOWNLOAD_URL is required"
  fi
  if [ ! -d ${UNZIP_DIR} ]; then
    mkdir -p ${UNZIP_DIR}
  fi
}

function get_remote_etag {
  curl -X HEAD -L ${DOWNLOAD_URL} -I -s > tmp_get_remote_etag
  REMOTE_ETAG=$(grep ETag tmp_get_remote_etag | awk -F ": " '{print $2}' | tr -d '\r\n')
  REMOTE_LAST_MODIFIED=$(grep Last-Modified tmp_get_remote_etag | awk -F ": " '{print $2}' | tr -d '\r\n')
  rm -f tmp_get_remote_etag
}

function get_local_etag {
  if [ -f "${IMG_DIR}/${LOCAL_FILE_NAME}.img" ]; then
    if [ -f "${IMG_DIR}/${LOCAL_FILE_NAME}.etag" ]; then
      LOCAL_ETAG=$(cat ${IMG_DIR}/${LOCAL_FILE_NAME}.etag | tr -d '\r\n')
    fi
    if [ -f "${IMG_DIR}/${LOCAL_FILE_NAME}.last-modified" ]; then
      LOCAL_LAST_MODIFIED=$(cat ${IMG_DIR}/${LOCAL_FILE_NAME}.last-modified | tr -d '\r\n')
    fi
  fi
}

function download_zip {
  if [ "${REMOTE_ETAG}" == "${LOCAL_ETAG}" ]; then
    info "IDENTICAL!! Skip to download"
  elif [ "${REMOTE_LAST_MODIFIED}" == "${LOCAL_LAST_MODIFIED}" ]; then
    info "IDENTICAL!! Skip to download"
  else
    echo ${REMOTE_ETAG} > "${IMG_DIR}/${LOCAL_FILE_NAME}.etag"
    echo ${REMOTE_LAST_MODIFIED} > "${IMG_DIR}/${LOCAL_FILE_NAME}.last-modified"
    rm -f "${IMG_DIR}/${LOCAL_FILE_NAME}.zip"
    curl -o "${IMG_DIR}/${LOCAL_FILE_NAME}.zip" -L ${DOWNLOAD_URL}
    if [ "$?" != "0" ]; then
      echo "cURL failure!"
      exit "$?"
    fi
  fi
}

function extract_img {
  rm -f "${IMG_DIR}/${LOCAL_FILE_NAME}.img"
  unzip -o "${IMG_DIR}/${LOCAL_FILE_NAME}.zip" -d ${UNZIP_DIR}
  EXT4=`ls ${UNZIP_DIR}/*.ext4`
  if [ "$?" == "0" ]; then
    cp -f ${EXT4} "${IMG_DIR}/${LOCAL_FILE_NAME}.img"
  else
    mv ${IMG_DIR}/2*.img ${IMG_DIR}/${LOCAL_FILE_NAME}.img
  fi
}

assert_args
get_local_etag
get_remote_etag
info "Remote ETag [${REMOTE_ETAG}]"
info "Local ETag  [${LOCAL_ETAG}]"

info "Remote Last-Modified [${REMOTE_LAST_MODIFIED}]"
info "Local Last-Modified  [${LOCAL_LAST_MODIFIED}]"

download_zip
extract_img
