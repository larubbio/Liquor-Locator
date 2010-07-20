import logging
from google.appengine.ext import db
from google.appengine.ext import webapp

from model.Model import Catalog, Category
import utils.JSONUtils as JSONUtils
import utils.Utils as Utils

class CategoriesHandler(webapp.RequestHandler):

    def get(self, cid):
        catalog = Utils.catalogFromId(self, int(cid))
        if catalog is None:
            return

        q = db.GqlQuery("SELECT * FROM Category where cid = :1", int(cid))

        categories = []
        for c in q.run():
            categories.append(c)

        response = JSONUtils.to_json(categories)
        logging.info('Response: %s' % response)
        
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(response)
