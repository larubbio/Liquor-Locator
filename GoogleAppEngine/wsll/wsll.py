from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

from handlers.CatalogsHandler import CatalogsHandler
from handlers.StoresHandler import StoresHandler
from handlers.SpiritHandler import SpiritHandler
from handlers.SpiritsHandler import SpiritsHandler
from handlers.SpiritInventoryHandler import SpiritInventoryHandler
from handlers.CategoriesHandler import CategoriesHandler

application = webapp.WSGIApplication(
                                     [('/catalogs', CatalogsHandler),
                                      ('/(.*)/spirits', SpiritsHandler),
                                      ('/(.*)/spirit/(.*)/stores', SpiritInventoryHandler),
                                      ('/(.*)/spirit/(.*)', SpiritHandler),
                                      ('/(.*)/stores', StoresHandler),
                                      ('/(.*)/categories', CategoriesHandler),
                                      ],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
