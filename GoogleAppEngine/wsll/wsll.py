from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

from handlers.CatalogsHandler import CatalogsHandler
from handlers.StoresHandler import StoresHandler
from handlers.SpiritsHandler import SpiritsHandler
from handlers.CategoriesHandler import CategoriesHandler

application = webapp.WSGIApplication(
                                     [('/catalogs', CatalogsHandler),
                                      ('/(.*)/stores', StoresHandler),
                                      ('/(.*)/spirits', SpiritsHandler),
                                      ('/(.*)/categories', CategoriesHandler),
                                      ],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
