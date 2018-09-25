#!/bin/env python
# -*- coding=utf-8 -*-

import cherrypy

class HelloWorld(object):
    def index(self):
        return "Hello universe!"
    index.exposed = True
cherrypy.quickstart(HelloWorld(),'/u/')
