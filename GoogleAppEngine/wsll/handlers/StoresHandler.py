import logging
from google.appengine.ext import db
from google.appengine.ext import webapp

from model.Model import Catalog, Store, Hours, Contact
import utils.JSONUtils as JSONUtils
import utils.Utils as Utils

class StoresHandler(webapp.RequestHandler):

    def get(self, cid):
        stores = []
        id = None
        brand_code = None
        lat = None
        long = None
        dist = None

        # If looking up a single store
        id = Utils.verifyArg(self, self.request.get('id'), 'id', int)

        # If looking for stores with a certain spirit
        brand_code = self.request.get('brand_code')

        # If looking for nearby stores
        lat = Utils.verifyArg(self, self.request.get('lat'), 'lat', float)
        long = Utils.verifyArg(self, self.request.get('long'), 'long', float)
        dist = Utils.verifyArg(self, self.request.get('dist'), 'dist', int)

        if id is not None:
            q = db.GqlQuery("SELECT * FROM Stores WHERE cid = :1 and store_number = :2", cid, id)

            stores = q.get()
        
        elif brand_code is not None:

            q = db.GqlQuery("SELECT * FROM Spirit WHERE cid = :1 and brand_code = :2", cid, brand_code)
            spirit = q.get()

            if spirit:
                for si in spirit.inventory():
                    stores.append(si.store())

        elif lat is not None and long is not None and dist is not None:
            pass

        else:

            q = db.GqlQuery("SELECT * FROM Stores WHERE cid = :1 and store_number = :2", cid, id)

            for s in q.run():
                stores.append(s)
            
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json(stores))
        
    def post(self, cid):
        logging.info("StoresHandler::post %s" % cid)

        body = self.request.body_file.getvalue()
        logging.info('Body: %s' % body)

        # load the catalog just to verify it exists
        catalog = Utils.catalogFromId(self, int(cid))
        if catalog is None:
            return

        s = JSONUtils.loads(body)

        store_type = s['store_type']
        retail = bool(s['retail_sales'])
        store_number = s['store_number']
        address = s['address']
        address2 = s['address2']
        city = s['city']
        zip = s['zip']

        if s['address2'] is None:
            a = db.PostalAddress("%s, %s, WA %s" % (address, city, zip))
        else:
            a = db.PostalAddress("%s, %s %s, WA %s" % (address, address2, city, zip))

        store = Store(cid=int(cid),
                      store_type=store_type,
                      retail=retail,
                      store_number=store_number,
                      address=a,
                      location=None)

        store.put()

        # Create the hours
        for h in s['hours']:
            hours = Hours(store=store,
                          cid=int(cid),
                          start_day=h['start_day'],
                          end_day=h['end_day'],
                          open=h['open'],
                          close=h['close'],
                          summer_hours=bool(h['summer_hours']))

            hours.put()

        # Create the store contacts
        for c in s['contacts']:
            key = "%s-%s-%s" % (cid, c['name'], c['number'])
            contact = Contact.get_or_insert(key_name=key,
                                            cid=int(cid),
                                            role=c['role'],
                                            name=c['name'],
                                            number=c['number'])

            contact.stores.append(store.key())
            contact.put()

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json(store))
        

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
