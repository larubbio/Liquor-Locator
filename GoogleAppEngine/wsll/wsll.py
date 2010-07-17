import datetime
import time

from django.utils import simplejson as json

from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app

from model.Model import *

SIMPLE_TYPES = (int, long, float, bool, dict, basestring, list)

def to_json(model):
    ret = ''

    if isinstance(model, list):
        elements = []
        for m in model:
            elements.append(m.to_dict())

        ret = json.dumps(elements)

    else:
   
        ret = json.dumps(model.to_dict())

    return ret

class CatalogsHandler(webapp.RequestHandler):
    def get(self):
        fetchnum = 10

        q = db.GqlQuery("SELECT * FROM Catalog")

        catalogs = q.fetch(fetchnum)
        catalogs.sort(key=lambda x: x.key().id(), reverse=True)

        self.response.headers.add_header('Content-Type', 'application/json')

        ret = ''
        if self.request.get('current'):
            ret = to_json(catalogs[:1])
        else:
            ret = to_json(catalogs)

        self.response.out.write(ret)

    def post(self):
        catalog = Catalog()
        catalog.created_date = datetime.date.today()
        catalog.status = "New"
        catalog.put()

        self.response.headers.add_header('Content-Type', 'application/json')
        self.response.out.write(to_json(catalog))     

class StoresHandler(webapp.RequestHandler):

    def get(self):
        pass

application = webapp.WSGIApplication(
                                     [('/catalogs', CatalogsHandler),
                                      ('(.*)/stores', StoresHandler)],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
