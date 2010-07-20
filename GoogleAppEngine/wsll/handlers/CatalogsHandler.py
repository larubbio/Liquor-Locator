import datetime
import time

from google.appengine.ext import db
from google.appengine.ext import webapp

from model.Model import Catalog
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

        catalog.delete()

        # Todo: delete all child data

        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(JSONUtils.to_json({'status':'success', 'msg':'Deleted catalog %s' % id}))

