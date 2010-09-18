import logging
import re
import simplejson
import sys
import urllib,urllib2

from sqlalchemy import create_engine
from model import Model

LOG_FILENAME = 'spirit_image_update.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

def loadURL(url, params=None):
    logging.info("Loading %s (%s)" % (url, params))

    retry_time = 1
    html = None

    while retry_time <= 256 and html is None:
        try:
            if params:
                data = urllib.urlencode(params) 
                request = urllib2.Request(url, data)
                response = urllib2.urlopen(request)
            else:
                response = urllib2.urlopen(url)

            html = response.read()
        except IOError as e:
            logging.error("I/O error: %s (%s)" % (e, retry_time))
            time.sleep(retry_time)
            retry_time = retry_time * 2
        except ValueError as e:
            logging.error("ValueError: %s (%s)" % (e, retry_time))
            time.sleep(retry_time)
            retry_time = retry_time * 2

    return html

def google_image_search(brand):
    url = None
    params = {'q' : brand,
              'v' : '1.0'}

    data = urllib.urlencode(params) 
    ret = loadURL('http://ajax.googleapis.com/ajax/services/search/images?%s' % data)
    json = simplejson.loads(ret)

    if json['responseStatus'] == 200:
        if (len(json['responseData']['results']) > 0):
            result = json['responseData']['results'][0]
            # TODO
            width = result['width']
            height = result['height']
            url = result['url']

            logging.info("Loading Image for %s" % (s.brand_name))
        else:
            logging.info("No Image for %s" % (s.brand_name))

    else:
        logging.error("Unexpected status code")
        logging.error(json)

    return url

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

spirits = session.query(Model.Spirit)

for s in spirits.all():
    if 'VODKA' in s.category:
        s.brand_name = s.brand_name.replace(' VK ', ' VODKA ')
        s.brand_name = s.brand_name.replace(' VKA ', ' VODKA ')

    if 'WHISKEY' in s.category:
        s.brand_name = s.brand_name.replace(' WHSK ', ' WHISKEY ')
        s.brand_name = s.brand_name.replace(' BBN ', ' BOURBON ')

    if 'WHISKY' in s.category:
        s.brand_name = s.brand_name.replace(' SC ', ' SCOTCH ')

    if 'TEQUILA' in s.category:
        s.brand_name = s.brand_name.replace(' TEQ ', ' TEQUILA ')

    if 'BRANDY' in s.category:
        s.brand_name = s.brand_name.replace(' BRDY ', ' BRANDY ')
        s.brand_name = s.brand_name.replace(' CGNC ', ' COGNAC ')

    s.image_url = google_image_search(s.brand_name)

session.commit()
