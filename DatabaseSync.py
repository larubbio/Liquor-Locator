import logging
import re
import simplejson
import sys
import time
import urllib,urllib2
import math

import html5lib
#from html5lib import treebuilders
#from lxml import etree

from BeautifulSoup import BeautifulSoup

from sqlalchemy import create_engine
from model import Model

LOG_FILENAME = '/home/rob/output.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

def geocode_store(store, address):
    params = {'q' : address,
              'key' : 'ABQIAAAAOtgwyX124IX2Zpe7gGhBsxS3tJNgUZ1nThh1KEATL8UWMaiosxQ7wZ2BhjWP4DLhPcIryslC442YvA',
              'sensor' : 'true',
              'output' : 'json',
              'oe' : 'utf8'}

    data = urllib.urlencode(params) 
    ret = loadURL('http://maps.google.com/maps/geo?%s' % data)
    json = simplejson.loads(ret)

    if json['Status']['code'] == 200:
        store.long = json['Placemark'][0]['Point']['coordinates'][0]
        store.lat = json['Placemark'][0]['Point']['coordinates'][1]
        
        store.long_rad = math.pi*store.long/180.0
        store.lat_rad = math.pi*store.lat/180.0

        logging.info("GeoCoding store %s (%s, %s) (%s, %s)" % (store.id, 
                                                               store.lat, 
                                                               store.long,
                                                               store.lat_rad,
                                                               store.long_rad))
    else:
        logging.error("Unexpected status code")
        logging.error(json)



def processHours(store, col):
    summer_hours = False

    for c in col.contents:

        l = str(c)
        l = l.replace('\n', '').replace('\r', '')

        # First look to see if we have moved into the summer hours
        if l.find('Summer') >= 0:
            summer_hours = True

        # If there is a : there is an hours range
        elif l.find(':') >= 0:
            (days, hours) = l.split(' ')
            days = days.split('-')
            hours = hours.split('-')

            start_day = days[0]
            if len(days) is 1:
                end_day = days[0]
            else:
                end_day = days[1]

            start_hour = hours[0]
            end_hour = hours[1]

            # Store the record
            hours = session.query(Model.StoreHours).filter(
                Model.StoreHours.store_id==store.id).filter(
                Model.StoreHours.start_day==start_day).filter(
                Model.StoreHours.end_day==end_day).filter(
                Model.StoreHours.open==start_hour).filter(
                Model.StoreHours.close==end_hour).filter(
                Model.StoreHours.summer_hours==summer_hours).first()

            if hours is None:
                hours = Model.StoreHours(store.id, 
                                         start_day,
                                         end_day,
                                         start_hour,
                                         end_hour,
                                         summer_hours)

                store.hours.append(hours)
            
        # Sun hours look to always be noon to 5pm
        elif l.find('Sun') >= 0:
            start_day = 'Sun'
            end_day = 'Sun'
            start_hour = '12:00'
            end_hour = '5:00'

            # Store the record
            hours = session.query(Model.StoreHours).filter(
                Model.StoreHours.store_id==store.id).filter(
                Model.StoreHours.start_day==start_day).filter(
                Model.StoreHours.end_day==end_day).filter(
                Model.StoreHours.open==start_hour).filter(
                Model.StoreHours.close==end_hour).filter(
                Model.StoreHours.summer_hours==summer_hours).first()

            if hours is None:
                hours = Model.StoreHours(store.id, 
                                         start_day,
                                         end_day,
                                         start_hour,
                                         end_hour,
                                         summer_hours)

                store.hours.append(hours)

def processContact(store, col):
    role = None

    for c in col.contents:
        l = str(c)

        if l.find('Manager') >= 0:
            if c.decodeContents().find('font') >= 0:
                c = c.findAll('font')[0]
            role = c.decodeContents().strip()[:-1]

        elif l.find('-') >= 0:
            (name, number) = c.decodeContents().strip().split('&nbsp;&nbsp;')
            name = name.strip()
            number = number[1:-1]

            # Store record
            contact = session.query(Model.StoreContact).filter(
                Model.StoreContact.role==role).filter(
                Model.StoreContact.name==name).filter(
                Model.StoreContact.number==number).first()

            if contact is None:
                contact = Model.StoreContact(role, name, number)

                store.contacts.append(contact)

            role = None

def processStoreAndSpiritInventory(spirit, row):
    cols = row.findAll('td')
    
    # Store Type
    store_type = cols[0].find('font').decodeContents().strip()[:-1]

    # Retail
    retail = not cols[0].decode().find("No Retail") >= 0

    # Store Number
    store_number = cols[0].contents[4]

    # City
#    city = cols[0].decodeContents()[:cols[0].decodeContents().find(' <br')]
    city = cols[0].contents[0]

    # Name
#    name = cols[1].decodeContents()[:cols[1].decodeContents().find(' <br')]
    name = cols[1].contents[0]

    # Address
    address1 = cols[1].contents[2]
    address2 = None

    if len(cols[1].contents) is 7:
        address2 = cols[1].contents[4]
        zip_line = cols[1].contents[6]
    else:
        zip_line = cols[1].contents[5]

    zip = zip_line[-10:]

    # Insert or update store and get id
    store = session.query(Model.Store).filter(Model.Store.id==store_number).first()

    if store is None:
        store = Model.Store(store_number)

        address = '%s %s WA, %s' % (address1, city, zip)
        geocode_store(store, address)

        store.name = name.strip()
        store.store_type = store_type
        store.retail_sales = retail
        store.city = city.strip()
        store.address = address1
        store.address2 = address2
        store.zip = zip

        # Hours
        processHours(store, cols[2])

        # Contact
        processContact(store, cols[3])

    # Quantity in Stock
    qty = cols[4].find('font').decodeContents()

    # Insert the spirit inventory TODO
    # Store the record
    inv = session.query(Model.StoreInventory).filter(
        Model.StoreInventory.store_id==store.id).filter(
        Model.StoreInventory.spirit_id==spirit.id).first()

    if inv is None:
        inv = Model.StoreInventory(store.id, 
                                   spirit.id)

    inv.qty = qty

    store.inventory.append(inv)
    spirit.inventory.append(inv)

def processSpirit(category, row):
    columns = row.findAll('td')

    # Brand Name
    brand_name = columns[0].findChild().decodeContents()

    # Brand Code
    brand_code = columns[1].findChild().decodeContents()

    # Retail Price
    retail_price = columns[2].decodeContents().replace('$', '').replace(',', '')

    # Sales Tax
    sales_tax = columns[3].decodeContents().replace('$', '')

    # Total Retail Price
    total_retail_price = columns[4].findChild().decodeContents().replace('$', '').replace(',', '')

    # Class H Price
    class_h_price = columns[5].decodeContents().replace('$', '').replace(',', '')

    # Merchandising Special Note
    special_note = unicode(columns[6].decodeContents())
    special_note.replace('<br />', '')

    # Size (Liters)
    size = columns[7].decodeContents()

    # Case Price
    case_price = columns[8].decodeContents().replace('$', '').replace(',', '')

    # Proof OR %
    proof = columns[9].decodeContents()

    # Liter Cost
    liter_cost = columns[10].decodeContents().replace('$', '').replace(',', '')

    # Insert or update the spirit record and get it's id
    spirit = session.query(Model.Spirit).filter(Model.Spirit.id==brand_code).first()

    if spirit is None:
        spirit = Model.Spirit(brand_code)

    # Clean up the names some
    if 'VODKA' in category:
        brand_name = brand_name.replace(' VK ', ' VODKA ')
        brand_name = brand_name.replace(' VKA ', ' VODKA ')

    if 'WHISKEY' in category:
        brand_name = brand_name.replace(' WHSK ', ' WHISKEY ')
        brand_name = brand_name.replace(' BBN ', ' BOURBON ')

    if 'WHISKY' in category:
        brand_name = brand_name.replace(' SC ', ' SCOTCH ')

    if 'TEQUILA' in category:
        brand_name = brand_name.replace(' TEQ ', ' TEQUILA ')

    if 'BRANDY' in category:
        brand_name = brand_name.replace(' BRDY ', ' BRANDY ')
        brand_name = brand_name.replace(' CGNC ', ' COGNAC ')

    spirit.category = category
    spirit.brand_name = brand_name
    spirit.retail_price = retail_price
    spirit.sales_tax = sales_tax
    spirit.total_retail_price = total_retail_price
    spirit.class_h_price = class_h_price
    spirit.merchandising_note = special_note
    spirit.size = size
    spirit.case_price = case_price
    spirit.proof = proof
    spirit.liter_cost = liter_cost
    spirit.on_sale = special_note.find('TEMP PRICE REDUCTION') >= 0
    spirit.closeout = special_note.find('CLOSEOUT') >= 0
#    spirit.image_url = image_url

    # For each click 'Find Store'
    params = {'CityName' : '', 'CountyName' : '', 'StoreNo' : '', 'brandcode' : brand_code}
    html = loadURL(STORE_SEARCH_URL, params)

    if html.find('No Products Found') is -1:

        page = BeautifulSoup(html)

        table = page.findAll('table')[3]
        rows = table.findAll('tr')[1:]

        for row in rows:
            processStoreAndSpiritInventory(spirit, row)   

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

# Old URLs
#BRAND_SEARCH_URL = 'http://liq.wa.gov/services/brandpicklist.asp'
#BRAND_CATEGORIES_URL = 'http://liq.wa.gov/services/brandsearch.asp'
#STORE_SEARCH_URL = 'http://liq.wa.gov/services/find_store.asp'

# New URLs
BRAND_SEARCH_URL = 'http://liq.wa.gov/homepageServices/brandpicklist.asp'
BRAND_CATEGORIES_URL = 'http://liq.wa.gov/homepageServices/brandsearch.asp'
STORE_SEARCH_URL = 'http://liq.wa.gov/homepageServices/find_store.asp'

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

# Truncate backup tables
session.execute("TRUNCATE TABLE contacts_bak")
session.execute("TRUNCATE TABLE hours_bak")
session.execute("TRUNCATE TABLE spirits_bak")
session.execute("TRUNCATE TABLE store_contacts_bak")
session.execute("TRUNCATE TABLE store_inventory_bak")
session.execute("TRUNCATE TABLE stores_bak")
session.execute("TRUNCATE TABLE distiller_spirits_bak")

# To make sure you're seeing all debug output:
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

parser = html5lib.HTMLParser(tree=treebuilders.getTreeBuilder("lxml"))
html = loadURL(BRAND_CATEGORIES_URL)

page = parser.parse(html)

categories = []
#for element in page.getroot().iter():
#    if element.tag == '{http://www.w3.org/1999/xhtml}option':
#        categories.append(element.text)

# Remove the first category which is just UI information
#categories = categories[1:]

#categories = ['APERITIF',]
categories = ['APERITIF', 'BRANDY', 'CIDER', 'COCKTAILS', 'GIN', 'INDUSTRIAL ALCOHOL - AVAILABLE BY PERMIT ONLY', 'LIQUEURS', 'MALT BEVERAGES', 'RUM', 'SCHNAPPS', 'SLOE GIN', 'SPIRIT - GIFT SELECTIONS', 'TEQUILA', 'VERMOUTH', 'VODKA', 'WHISKEY - AMERICAN BLEND', 'WHISKEY - BOURBON', 'WHISKEY - KENTUCKY & TENNESSEE', 'WHISKEY - OTHER - DOMESTIC', 'WHISKEY - RYE', 'WHISKY - CANADIAN', 'WHISKY - IRISH', 'WHISKY - OTHER - IMPORTED', 'WHISKY - SCOTCH', 'WINE - ALL OTHERS', 'WINE - DESSERT', 'WINE - FRUIT FLAVORED', 'WINE - GIFT SELECTIONS', 'WINE - IMPORTED - MISC', 'WINE - PINK TABLE', 'WINE - RED TABLE', 'WINE - SANGRIA', 'WINE - SPARKLING & CHAMPAGNE', 'WINE - UNLISTED - HUB STORES', 'WINE - WHITE TABLE']

for c in categories:
    logging.info(c)

    params = {'BrandName' : '', 'CatBrand' : c, 'submit1' : 'Find Product' }
    html = loadURL(BRAND_SEARCH_URL, params)

    # Only record the spirit if it is in stock
    if html.find('out of stock') is -1:
        # Parse the page 
        page = BeautifulSoup(html)

        # Loop over each row storing spirit information
        table = page('table')[3]
        rows = table.findAll('tr')[1:]

        for row in rows:
            processSpirit(c, row)

# Set up local distillers

# For each local distiller
distillers = session.query(Model.Distiller).filter(Model.Distiller.search_term!=None)
for d in distillers.all():

    if d.search_term:
        for term in d.search_term.split(','):
            search_term = '%' + term + '%'

            # select all spirits that match search_term
            spirits = session.query(Model.Spirit).filter(Model.Spirit.brand_name.like(search_term))

            for s in spirits.all():
                d.spirits.append(s)
                                          
   #Swap live tables with backups
   # session.execute('''RENAME TABLE 
   #   contacts TO contacts_tmp,
   #   hours TO hours_tmp,
   #   spirits TO spirits_tmp,
   #   store_contacts TO store_contacts_tmp,
   #   store_inventory TO store_inventory_tmp,
   #   stores TO stores_tmp,
   #   local_distillers TO local_distillers_tmp,
   #   distiller_spirits TO distiller_spirits_tmp,
   
   #   contacts_bak TO contacts,
   #   hours_bak TO hours,
   #   spirits_bak TO spirits,
   #   store_contacts_bak TO store_contacts,
   #   store_inventory_bak TO store_inventory,
   #   stores_bak TO stores,
   #   local_distillers_bak TO local_distillers,
   #   distiller_spirits_bak TO distiller_spirits,
   
   #   contacts_tmp TO contacts_bak,
   #   hours_tmp TO hours_bak,
   #   spirits_tmp TO spirits_bak,
   #   store_contacts_tmp TO store_contacts_bak,
   #   store_inventory_tmp TO store_inventory_bak,
   #   stores_tmp TO stores_bak,
   #   local_distillers_tmp to local_distillers_bak,
   #   distiller_spirits_tmp TO distiller_spirits_bak
   # ''')

session.commit()
