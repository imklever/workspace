#!/bin/env python
import cherrypy

@cherrypy.expose
class HelloWorld(object):
    def index(self):
        return "hello Hello"

    def hello(self):
        return "hello"

@cherrypy.expose
class Blog1(object):
    def index(self):
        return "hello Blog1"

    def blog(self):
        return "blog1"

@cherrypy.expose
class Blog2(object):
    def index(self):
        return "hello Blog2"

    def blog(self):
        return "blog2"

if __name__ == '__main__':
    #cherrypy.config.update({'server.socket_host': '10.240.217.156'})
    #cherrypy.quickstart(HelloWorld())
    #cherrypy.tree.mount(HelloWorld(), '/', {'/': {'server.socket_host': '10.240.217.156'}})

    cherrypy.config.update({'server.socket_host': '0.0.0.0'})

    #cherrypy.tree.mount(Blog1(), '/Blog1') 
    #cherrypy.tree.mount(Blog2(), '/Blog2') 
    #cherrypy.tree.mount(HelloWorld(), '/Hello') 
    cherrypy.tree.mount(Blog1(), '/Blog1', './config') 
    cherrypy.tree.mount(Blog2(), '/Blog2', './config') 
    cherrypy.tree.mount(HelloWorld(), '/Hello', './config') 
    #cherrypy.tree.mount(Blog1(), '/Blog1', {'/Blog1': {'tools.response_headers.on': True}})
    #cherrypy.tree.mount(Blog2(), '/Blog2', {'/Blog2': {'tools.response_headers.on': True}})
    #cherrypy.tree.mount(HelloWorld(), '/Hello', {'/Hello': {'tools.response_headers.on': True}})

    cherrypy.engine.start()
    cherrypy.engine.block()
    cherrypy.engine.stop()
