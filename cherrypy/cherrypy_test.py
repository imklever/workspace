#!/bin/env python

#import cherrypy
#class HelloWorld(object):
#    @cherrypy.expose
#    def index(self):
#        host = cherrypy.request.headers['Host']
#        return "You have successfully reached " + host
#cherrypy.quickstart(HelloWorld())



###############################################################################
#import random
#import string
#
#import cherrypy
#
#class StringGenerator(object):
#    @cherrypy.expose(['generer', 'generar'])
#    def generate(self, length=8):
#        return ''.join(random.sample(string.hexdigits, int(length)))
#
#if __name__ == '__main__':
#    cherrypy.quickstart(StringGenerator())



###############################################################################
import cherrypy

@cherrypy.popargs('band_name')
class Band(object):
    def __init__(self):
        self.albums = Album()

    @cherrypy.expose
    def index(self, band_name):
        return 'About %s...' % band_name

@cherrypy.popargs('album_title')
class Album(object):
    @cherrypy.expose
    def index(self, band_name, album_title):
        return 'About %s by %s...' % (album_title, band_name)

if __name__ == '__main__':
    cherrypy.quickstart(Band())
