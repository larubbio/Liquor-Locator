import logging
import re
import simplejson
import sys
import time
import urllib,urllib2
import math

import html5lib
from sqlalchemy import create_engine
from model import Model

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

#Swap live tables with backups
session.execute('''RENAME TABLE 
     contacts TO contacts_tmp,
     hours TO hours_tmp,
     spirits TO spirits_tmp,
     store_contacts TO store_contacts_tmp,
     store_inventory TO store_inventory_tmp,
     stores TO stores_tmp,
     local_distillers TO local_distillers_tmp,
     distiller_spirits TO distiller_spirits_tmp,
   
     contacts_bak TO contacts,
     hours_bak TO hours,
     spirits_bak TO spirits,
     store_contacts_bak TO store_contacts,
     store_inventory_bak TO store_inventory,
     stores_bak TO stores,
     local_distillers_bak TO local_distillers,
     distiller_spirits_bak TO distiller_spirits,
   
     contacts_tmp TO contacts_bak,
     hours_tmp TO hours_bak,
     spirits_tmp TO spirits_bak,
     store_contacts_tmp TO store_contacts_bak,
     store_inventory_tmp TO store_inventory_bak,
     stores_tmp TO stores_bak,
     local_distillers_tmp to local_distillers_bak,
     distiller_spirits_tmp TO distiller_spirits_bak
   ''')

session.commit()
