import logging
import re
import sys
import urllib,urllib2
import simplejson
import math

from sqlalchemy import create_engine
from model import Model

LOG_FILENAME = 'geocode.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

def loadURL(url, params=None):
    logging.info("Loading %s (%s)" % (url, params))

    retry_time = 1
    html = None

    while retry_time <= 256 and html is None:
        try:
            if params:
                data = urllib.urlencode(params) 
                request = urllib2.Request('%s?%s' % (url, data))
                response = urllib2.urlopen(request)
            else:
                response = urllib2.urlopen(url)

            html = response.read()
        except IOError as (errno, strerror):
            logging.debug("I/O error(%s): %s (%s)" % (errno, strerror, retry_time))
            time.sleep(retry_time)
            retry_time = retry_time * 2

    return html

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

stores = session.query(Model.Store)

for s in stores.all():
    address = None
    address = '%s %s WA, %s' % (s.address, s.city, s.zip)

    params = {'q' : address,
              'key' : 'ABQIAAAAOtgwyX124IX2Zpe7gGhBsxS3tJNgUZ1nThh1KEATL8UWMaiosxQ7wZ2BhjWP4DLhPcIryslC442YvA',
              'sensor' : 'true',
              'output' : 'json',
              'oe' : 'utf8'}

    ret = loadURL('http://maps.google.com/maps/geo', params)
    json = simplejson.loads(ret)

    if json['Status']['code'] == 200:
        s.long = json['Placemark'][0]['Point']['coordinates'][0]
        s.lat = json['Placemark'][0]['Point']['coordinates'][1]

        s.long_rad = math.pi*s.long/180.0
        s.lat_rad = math.pi*s.lat/180.0

        logging.info("GeoCoding store %d (%s, %s) (%s, %s)" % (s.id, 
                                                               s.lat, s.long,
                                                               s.lat_rad, s.long_rad))

        session.add(s)
    else:
        logging.error("Unexpected status code")
        logging.error(json)

session.commit()
