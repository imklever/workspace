#!/bin/env python
# -*- coding=utf-8 -*-

import cherrypy
import time

class WebApp(object):
    @cherrypy.expose
    def index(self):
        return file('../WIKI/index.html')

    @cherrypy.expose
    def nihao(self):
        return "nihao!\n"

@cherrypy.expose
class Rest_1(object):

    @cherrypy.tools.accept(media='text/plain')

    def GET(self):
        #time.sleep(10)
        return "get rest_1\n"
    def POST(self, length=8):
        str = "post rest_1 length="+length+"\n"
        return str
    def PUT(self):
        return "put rest_1\n"
    def DELETE(self):
        return "delete rest_1\n"

@cherrypy.expose
class Rest_2(object):

    @cherrypy.tools.accept(media='text/plain')


    def GET(self):
        return "get rest_2\n"
    def POST(self, length=8):
        str = "post rest_2 length="+length+"\n"
        return str
    def PUT(self):
        return "put rest_2\n"
    def DELETE(self):
        return "delete rest_2\n"

if __name__ == '__main__':
    webapp = WebApp()
    webapp.rest1 = Rest_1()
    webapp.rest2 = Rest_2()
    cherrypy.quickstart(webapp, '/', './config')