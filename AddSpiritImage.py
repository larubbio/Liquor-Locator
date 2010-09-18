import logging
import re
import simplejson
import sys
import urllib,urllib2

from sqlalchemy import create_engine
from model import Model

LOG_FILENAME = 'spirit_image_update.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)


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

session.commit()
