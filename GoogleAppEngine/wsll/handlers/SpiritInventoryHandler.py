import logging
from google.appengine.ext import db
from google.appengine.ext import webapp

from model.Model import Catalog, Spirit, Store, StoreInventory
import utils.JSONUtils as JSONUtils
import utils.Utils as Utils

class SpiritInventoryHandler(webapp.RequestHandler):

    def post(self, cid, brand_code):
        logging.info("SpiritInventoryHandler::get %s" % cid)

        body = self.request.body_file.getvalue()
        logging.info('Body: %s' % body)

        # load the catalog just to verify it exists
        catalog = Utils.catalogFromId(self, int(cid))
        if catalog is None:
            return

        s = JSONUtils.loads(body)

        store_id = s['store_id']
        qty = s['quantity']

        spirit = db.GqlQuery("SELECT * FROM Spirit where cid = :1 AND brand_code = :2", int(cid), brand_code).get()

        store = db.GqlQuery("SELECT * FROM Store where cid = :1 AND store_number = :2", int(cid), store_id).get()

        si_key = StoreInventory(cid=int(cid),
                                spirit=spirit,
                                store=store,
                                quantity=qty).put()

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json(db.get(si_key)))
        
