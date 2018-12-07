#!/bin/bash

DES_PATH="/usr/share/nginx/html"

echo "hello"

cd `dirname $0`

#ssh ${DES_HOST} "rm -f ${DES_PATH}/index.html"
#ssh ${DES_HOST} "rm -f ${DES_PATH}/code/*"

rm -rf ${DES_PATH}/html/
rm -rf ${DES_PATH}/css/
rm -rf ${DES_PATH}/js/
rm -rf ${DES_PATH}/icon/
rm -rf ${DES_PATH}/picture/
mkdir ${DES_PATH}/html/
mkdir ${DES_PATH}/css/
mkdir ${DES_PATH}/js/
mkdir ${DES_PATH}/icon/
mkdir ${DES_PATH}/picture/

cp ./index.html ${DES_PATH}/
cp ./html/* ${DES_PATH}/html/
cp ./css/* ${DES_PATH}/css/
cp ./js/* ${DES_PATH}/js/
cp ./icon/* ${DES_PATH}/icon/
cp ./picture/* ${DES_PATH}/picture/
