import logging
import re
import sys

from sqlalchemy import create_engine
from model import Model

LOG_FILENAME = 'craft_update.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

session.execute("TRUNCATE TABLE distiller_spirits_bak")

stores = session.query(Model.Store)

distillers = session.query(Model.Distiller).filter(Model.Distiller.search_term!=None)
for d in distillers.all():

    if d.search_term:
        for term in d.search_term.split(','):

            search_term = '%' + term + '%'

            # select all spirits that match search_term
            spirits = session.query(Model.Spirit).filter(Model.Spirit.brand_name.like(search_term))

            for s in spirits.all():
                d.spirits.append(s)
                                          

# Swap live tables with backups
session.execute('''RENAME TABLE 
  distiller_spirits TO distiller_spirits_tmp,

  distiller_spirits_bak TO distiller_spirits,

  distiller_spirits_tmp TO distiller_spirits_bak
''')

session.commit()
