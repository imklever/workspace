#!/bin/bash

yum install -y nginx
rm -f /etc/nginx/nginx.conf
cp ./nginx.conf /etc/nginx/nginx.conf
