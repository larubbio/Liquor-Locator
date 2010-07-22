import logging
from google.appengine.ext import db
from google.appengine.ext import webapp

from model.Model import Catalog, Spirit, Category
import utils.JSONUtils as JSONUtils
import utils.Utils as Utils

class SpiritHandler(webapp.RequestHandler):

    def get(self, cid, brand_code):
        logging.info("SpiritHandler::get %s" % cid)

        # load the catalog just to verify it exists
        catalog = Utils.catalogFromId(self, int(cid))
        if catalog is None:
            return

        q = db.GqlQuery("SELECT * FROM Spirit where cid = :1 AND brand_code = :2", 
                        int(cid), brand_code)

        spirit = q.get()

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json(spirit))
        
