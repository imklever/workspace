#!/bin/bash

DES="/usr/share/nginx/html"
echo "hello"

rm -f ${DES}/index.html
rm -f ${DES}/code/*


cp ./index.html ${DES}/
cp ./src/* ${DES}/code/
cp ./png/* ${DES}/code/
