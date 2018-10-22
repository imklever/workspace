#!/bin/bash

DES_HOST="10.240.217.107"
DES_PATH="/usr/share/nginx/html"
echo "hello"



#ssh ${DES_HOST} "rm -f ${DES_PATH}/index.html"
#ssh ${DES_HOST} "rm -f ${DES_PATH}/code/*"

ssh ${DES_HOST} "rm -rf ${DES_PATH}/html/"
ssh ${DES_HOST} "rm -rf ${DES_PATH}/css/"
ssh ${DES_HOST} "rm -rf ${DES_PATH}/js/"
ssh ${DES_HOST} "rm -rf ${DES_PATH}/icon/"
ssh ${DES_HOST} "rm -rf ${DES_PATH}/picture/"

ssh ${DES_HOST} "mkdir ${DES_PATH}/html/"
ssh ${DES_HOST} "mkdir ${DES_PATH}/css/"
ssh ${DES_HOST} "mkdir ${DES_PATH}/js/"
ssh ${DES_HOST} "mkdir ${DES_PATH}/icon/"
ssh ${DES_HOST} "mkdir ${DES_PATH}/picture/"

scp ./index.html ${DES_HOST}:${DES_PATH}/
scp ./html/* ${DES_HOST}:${DES_PATH}/html/
scp ./css/* ${DES_HOST}:${DES_PATH}/css/
scp ./js/* ${DES_HOST}:${DES_PATH}/js/
scp ./icon/* ${DES_HOST}:${DES_PATH}/icon/
scp ./picture/* ${DES_HOST}:${DES_PATH}/picture/
