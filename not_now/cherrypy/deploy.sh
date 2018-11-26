#!/bin/bash

if [ ! -d /etc/cherrypy/ ];then
    mkdir /etc/cherrypy/
fi

cp ./config /etc/cherrypy/

