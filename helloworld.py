import cherrypy

class HelloWorld(object):
   @cherrypy.expose
   def index(self):
      return "hello world"

class Blog(object):
   @cherrypy.expose
   def blog(self):
      return "blog"

if __name__ == '__main__':
   #cherrypy.config.update({'server.socket_host': '10.240.217.156'})
   #cherrypy.quickstart(HelloWorld())
   #cherrypy.tree.mount(HelloWorld(), '/', {'/': {'server.socket_host': '10.240.217.156'}})
   cherrypy.tree.mount(Blog(), '/blog', {'/blog': {'server.socket_host': '10.240.217.156'}})

   cherrypy.engine.start()
   cherrypy.engine.block()
