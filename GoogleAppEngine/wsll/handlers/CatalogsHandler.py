import datetime
import time

from google.appengine.ext import db
from google.appengine.ext import webapp

from models import Catalog
import utils.JSONUtils as JSONUtils
import utils.Utils as Utils

class CatalogsHandler(webapp.RequestHandler):
    def get(self):
        catalogs = []

        q = db.GqlQuery("SELECT * FROM Catalog")

        for c in q.run():
            catalogs.append(c)

        catalogs.sort(key=lambda x: x.key().id(), reverse=True)

        ret = ''
        if self.request.get('current'):
            ret = JSONUtils.to_json(catalogs[:1])
        else:
            ret = JSONUtils.to_json(catalogs)

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(ret)

    def post(self):
        catalog = Catalog()
        catalog.created_date = datetime.date.today()
        catalog.status = "New"
        catalog.put()

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json(catalog))     

    def delete(self):
        id = Utils.verifyRequiredArg(self, self.request.get('id'), 'id', int)

        if id is None:
            return

        catalog = Utils.catalogFromId(self, id)
        if catalog is None:
            return

        # Todo: delete all child data
        q = db.GqlQuery("SELECT * FROM Store WHERE cid = :1", id)
        
        for store in q.run():
            
            # Delete all hours
            for h in store.hours:
                h.delete()

            # Delete the contacts
            for c in store.contacts:
                c.delete()

            store.delete()

        q = db.GqlQuery("SELECT * FROM Spirit WHERE cid = :1", id)
        for s in q.run():
            # Delete the inventory
            for i in s.inventory:
                i.delete()

            s.delete()

        q = db.GqlQuery("SELECT * FROM Category WHERE cid = :1", id)
        for s in q.run():
            s.delete()

        q = db.GqlQuery("SELECT * FROM  WHERE cid = :1", id)
        for s in q.run():
            s.delete()

        catalog.delete()

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json({'status':'success', 'msg':'Deleted catalog %s' % id}))

