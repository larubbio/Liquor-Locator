import logging
import re
import simplejson as json
import sys
import time
import urllib,urllib2

from sqlalchemy import create_engine
from model import Model

LOG_FILENAME = 'gae-update.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

#base_url = 'http://localhost:8080/'
base_url = 'http://liquorlocator.appspot.com/'
catalogs_url = base_url + 'catalogs'

def loadURL(url, method='get', params=None):
    data = None

    if params and method in ['get', 'delete']:
        data = urllib.urlencode(params) 
    else:
        data = params

    if data:
        if method in ['get', 'delete']:
            request = urllib2.Request('%s?%s' % (url, data))

        if method in ['post', 'put']:
            request = urllib2.Request(url, data=data)

    else:
        request = urllib2.Request(url)
        if method in ['post']:
            request.headers['Content-Length'] = 0
        
    request.get_method = lambda: method.upper()

    json_str = None

    try:
        response = urllib2.urlopen(request)
        json_str = response.read()
    except urllib2.HTTPError, e:
        logging.error("HTTPError (%s): %s" % (e.code, e.msg))
        json_str = e.read()

    return json_str

# Create a catalog
logging.info("loading %s" % catalogs_url)
catalog = json.loads( loadURL(catalogs_url, method='post') )

# TODO: Validate catalog was created

spirits_url = '%s%d/spirits' % (base_url, catalog['id'])
stores_url = '%s%d/stores' % (base_url, catalog['id'])

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

# To make sure you're seeing all debug output:
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# Upload all stores
for store in session.query(Model.Store):
    logging.info("Adding Store %s in %s" % (store.id, store.city))

    hours = []
    contacts = []

    # Select store hours
    for h in store.hours:
        hours.append({'start_day': h.start_day, 
                      'end_day': h.end_day, 
                      'open':h.open,
                      'close':h.close,
                      'summer_hours':h.summer_hours,})

    # Select store contacts
    for c in store.contacts:
        contacts.append({'role': c.role,
                         'name': c.name,
                         'number': c.number,})
    
    params = json.dumps({'store_type':store.store_type,
                         'retail_sales': store.retail_sales,
                         'store_number': store.id,
                         'city': store.city,
                         'address': store.address,
                         'address2': store.address2,
                         'zip':store.zip,
                         'hours' : hours,
                         'contacts' : contacts,
                         })

    s = loadURL(stores_url, method='post', params=params)

    # Validate store

# Upload all spirits
for spirit in session.query(Model.Spirit):
    logging.info("Adding Spirit %s (%s)" % (spirit.brand_name, spirit.id))

    # Set up inventory
    inv = []

    # Insert inventory
    for i in spirit.inventory:
        inv.append({'store_id': i.store_id, 
                    'quantity': i.qty,})

    params = json.dumps({'brand_code': spirit.id,
                         'category': spirit.category,
                         'brand_name': spirit.brand_name,
                         'retail_price': str(spirit.retail_price),
                         'sales_tax': str(spirit.sales_tax),
                         'total_retail_price': str(spirit.total_retail_price),
                         'class_h_price': str(spirit.class_h_price),
                         'merchandising_note': spirit.merchandising_note,
                         'size': str(spirit.size),
                         'case_price': str(spirit.case_price),
                         'liter_cost': str(spirit.liter_cost),
                         'proof': spirit.proof,
                         'on_sale': spirit.on_sale,
                         'closeout': spirit.closeout,
                         'inventory': inv,
                         })

    s = loadURL(spirits_url, method='post', params=params)

    # TODO: Validate spirit was created


# Update catalog from NEW to ACTIVE

