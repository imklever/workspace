#!/bin/env python
# -*- coding=utf-8 -*-

import cherrypy

class HelloWorld(object):
    def index(self):
        return "Hello World!\n"
    index.exposed = True




if __name__ == '__main__':
    cherrypy.quickstart(HelloWorld(), '/nihao', {'global': {'server.socket_port': 9090}})
