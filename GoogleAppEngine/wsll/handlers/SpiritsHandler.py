import logging
from google.appengine.ext import db
from google.appengine.ext import webapp

from models import Spirit, Category, StoreInventory
import utils.JSONUtils as JSONUtils
import utils.Utils as Utils

class SpiritsHandler(webapp.RequestHandler):

    def get(self, cid):
        pass

    def post(self, cid):
        logging.info("SpiritsHandler::post %s" % cid)

        body = self.request.body_file.getvalue()
        logging.info('Body: %s' % body)

        # load the catalog just to verify it exists
        catalog = Utils.catalogFromId(self, int(cid))
        if catalog is None:
            return

        s = JSONUtils.loads(body)

        category = s['category']
        brand_code = s['brand_code']
        brand_name = s['brand_name']
        retail_price = float(s['retail_price'])
        sales_tax = float(s['sales_tax'])
        total_retail_price = float(s['total_retail_price'])
        class_h_price = float(s['class_h_price'])
        merchandising_note = s['merchandising_note']
        size = float(s['size'])
        case_price = float(s['case_price'])
        liter_cost = float(s['liter_cost'])
        proof = int(s['proof'])
        on_sale = bool(s['on_sale'])
        closeout = bool(s['closeout'])

        spirit = Spirit(cid=int(cid),
                        category=category,
                        brand_code=brand_code,
                        brand_name=brand_name,
                        retail_price=retail_price,
                        sales_tax=sales_tax,
                        total_retail_price=total_retail_price,
                        class_h_price=class_h_price,
                        merchandising_note=merchandising_note,
                        size=size,
                        case_price=case_price,
                        liter_cost=liter_cost,
                        proof=proof,
                        on_sale=on_sale,
                        closeout=closeout)
        spirit.put()

        # Create the inventory
        for i in s['inventory']:
            store_id = i['store_id']
            qty = i['quantity']

            store = db.GqlQuery("SELECT * FROM Store where cid = :1 AND store_number = :2", int(cid), store_id).get()
            
            StoreInventory(cid=int(cid),
                           spirit=spirit,
                           store=store,
                           quantity=qty).put()


        # Add this category to the category list if it isn't there already
        key = "%s-%s" % (cid, category)
        category = Category.get_or_insert(key_name=key,
                                          cid=int(cid),
                                          name=category)

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json(spirit))
        

    def delete(self, cid):
        id = Utils.verifyIntArg(self, self.request.get('id'), 'id')

        if id is None:
            return

        catalog = Utils.catalogFromId(self, cid)
        if catalog is None:
            return

        # Load the store and delete it
#        catalog.delete()

        # Todo: delete all child data

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json({'status':'success', 'msg':'Deleted catalog %s' % id}))
