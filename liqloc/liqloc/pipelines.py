# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/topics/item-pipeline.html
import sys
sys.path.append('..')

from scrapy.xlib.pydispatch import dispatcher
from scrapy import signals
from scrapy.exceptions import DropItem
from scrapy.stats import stats
from scrapy import log
from scrapy.mail import MailSender

import simplejson
import time
import urllib,urllib2
import math

from sqlalchemy import create_engine
from sqlalchemy.sql import text
from model import Model

from liqloc.items import Category
from liqloc.items import Spirit
from liqloc.items import Store
from liqloc.items import StoreContact
from liqloc.items import StoreHours
from liqloc.items import StoreInventory

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

class DuplicatesPipeline(object):
    def __init__(self):
        self.duplicates = {}
        dispatcher.connect(self.spider_opened, signals.spider_opened)
        dispatcher.connect(self.spider_closed, signals.spider_closed)

    def spider_opened(self, spider):
        self.duplicates[spider] = {}

        self.duplicates[spider]['categories'] = set()
        self.duplicates[spider]['spirits'] = set()
        self.duplicates[spider]['stores'] = set()
        self.duplicates[spider]['contacts'] = set()
        self.duplicates[spider]['hours'] = set()
        self.duplicates[spider]['inventory'] = set()

    def spider_closed(self, spider):
        del self.duplicates[spider]

    def process_item(self, item, spider):
        (key, dataset) = self.generateKey(item)

        if key in self.duplicates[spider][dataset]:
            stats.inc_value("%s_dupe" % dataset)
            raise DropItem("Duplicate item found: %s" % item)
        else:
            self.duplicates[spider][dataset].add(key)
            return item

    def generateKey(self, item):
        t = type(item)
        
        if t is Category:
            key = item['name']
            dataset = 'categories'
        elif t is Spirit:
            key = item['code']
            dataset = 'spirits'
        elif t is Store:
            key = item['number']
            dataset = 'stores'
        elif t is StoreInventory:
            key = "%s-%s" % (item['store'], item['spirit'])
            dataset = 'inventory'

        return (key, dataset)

class SpiritCleanerPipeline(object):
    def process_item(self, item, spider):
        t = type(item)
        
        if t is Spirit:
            # Parse up merchandising note
            if "TEMP PRICE REDUCTION" in item['merchandisingSpecialNotes']:
                item['on_sale'] = True

            if "CLOSEOUT" in item['merchandisingSpecialNotes']:
                item['closeout'] = True

            if "NEW ITEM" in item['merchandisingSpecialNotes']:
                item['new_item'] = True

            if "ONE TIME ONLY" in item['merchandisingSpecialNotes']:
                item['one_time_only'] = True

            if "HOLIDAY/GIFT ITEM" in item['merchandisingSpecialNotes']:
                item['gift_item'] = True

            if "PART CASE AVAILABILITY" in item['merchandisingSpecialNotes']:
                item['part_case'] = True

            # Clean up name abbreviations
            if 'VODKA' in item['category']:
                item['name'] = item['name'].replace(' VK', ' VODKA ')
                item['name'] = item['name'].replace(' VKA', ' VODKA ')

            if 'WHISKEY' in item['category']:
                item['name'] = item['name'].replace(' WHSK', ' WHISKEY ')
                item['name'] = item['name'].replace(' BBN', ' BOURBON ')

            if 'WHISKY' in item['category']:
                item['name'] = item['name'].replace(' SC', ' SCOTCH ')

            if 'TEQUILA' in item['category']:
                item['name'] = item['name'].replace(' TEQ', ' TEQUILA ')

            if 'BRANDY' in item['category']:
                item['name'] = item['name'].replace(' BRDY', ' BRANDY ')
                item['name'] = item['name'].replace(' CGNC', ' COGNAC ')

        return item

class GeoCodeStorePipeline(object):

    def process_item(self, item, spider):
        t = type(item)
        if t is Store:
            self.geocodeStore(item)

        return item

    def geocodeStore(self, store):
        log.msg("GeoCoding store %s" % (store['number']), log.INFO)
        address = '%s %s WA, %s' % (store['address'], store['city'], store['zip'])
        params = {'q' : address,
                  'key' : 'ABQIAAAAOtgwyX124IX2Zpe7gGhBsxS3tJNgUZ1nThh1KEATL8UWMaiosxQ7wZ2BhjWP4DLhPcIryslC442YvA',
                  'sensor' : 'true',
                  'output' : 'json',
                  'oe' : 'utf8'}

        stats.inc_value("geocode")
        data = urllib.urlencode(params) 
        ret = self.loadURL('http://maps.google.com/maps/geo?%s' % data)
        json = simplejson.loads(ret)

        if json['Status']['code'] == 200:
            store['long'] = json['Placemark'][0]['Point']['coordinates'][0]
            store['lat'] = json['Placemark'][0]['Point']['coordinates'][1]
        
            store['longRad'] = math.pi*store['long']/180.0
            store['latRad'] = math.pi*store['lat']/180.0

        else:
            log.msg("Unexpected status code", log.ERROR)
            log.msg(json, log.ERROR)

    def loadURL(self, url, params=None):
        log.msg("Loading %s (%s)" % (url, params), log.INFO)

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
                log.msg("I/O error: %s (%s)" % (e, retry_time), log.ERROR)
                time.sleep(retry_time)
                retry_time = retry_time * 2
            except ValueError as e:
                log.msg("ValueError: %s (%s)" % (e, retry_time), log.ERROR)
                time.sleep(retry_time)
                retry_time = retry_time * 2

        return html

# Verifies the item is complete
class ValidateItemPipeline(object):

    def process_item(self, item, spider):
        t = type(item)
        
        if t is Spirit:
            if not self.validateSpirit(item):
                log.msg("Invalid Spirit %s" % item, log.ERROR)
        elif t is Store:
            if not self.validateStore(item):
                log.msg("Invalid Store %s" % item, log.ERROR)
        elif t is StoreInventory:
            pass

        return item

    def validateSpirit(self, spirit):
        ret = True

        ret = len(spirit['code'])
        ret = len(spirit['name'])
        ret = len(spirit['retailPrice'])
        ret = len(spirit['totalRetailPrice'])
        ret = len(spirit['size'])

        return ret

    def validateStore(self, store):
        ret = True

        ret = len(store['number'])
        ret = len(store['city'])
        ret = len(store['address'])
        ret = len(store['zip'])
#        ret = len(store['lat'])
#        ret = len(store['long'])
        ret = len(store['contacts'])
        ret = len(store['hours'])

        return ret

# Saves the item to the database
class SaveItemPipeline(object):

    def process_item(self, item, spider):
        t = type(item)

        if t is Category:
            pass
        elif t is Spirit:
            item['size_name'] = self.nameForSize(item['size'])

            spirit = Model.Spirit(item['code'])

            spirit.category = item['category']
            spirit.brand_name = item['name']
            spirit.retail_price = item['retailPrice']
            spirit.sales_tax = item['salesTax']
            spirit.total_retail_price = item['totalRetailPrice']
            spirit.class_h_price = item['classHPrice']
            spirit.merchandising_note = item['merchandisingSpecialNotes']
            spirit.size = item['size']
            spirit.size_name = item['size_name']
            spirit.case_price = item['casePrice']
            spirit.proof = item['proof']
            spirit.liter_cost = item['literCost']
            spirit.on_sale = item['on_sale']
            spirit.closeout = item['closeout']
            spirit.new_item = item['new_item']
            spirit.one_time_only = item['one_time_only']
            spirit.gift_item = item['gift_item']
            spirit.part_case = item['part_case']

            stats.inc_value("spirits")

        elif t is Store:
            store = Model.Store(item['number'])

            store.name = item['name']
#            store.store_type = item['store_type']
#            store.retail_sales = item['retail']
            store.city = item['city']
            store.address = item['address']
            store.address2 = item['address2']
            store.zip = item['zip']

            if 'lat' in item:
                store.lat = item['lat']
                store.long = item['long']
                store.lat_rad = item['latRad']
                store.long_rad = item['longRad']

            stats.inc_value("stores")

            for contact in item['contacts']:
                role = contact['role']
                name = contact['name']
                number = contact['number']

                # Check for duplicate contact
                contact = session.query(Model.StoreContact).filter(
                    Model.StoreContact.role==role).filter(
                    Model.StoreContact.name==name).filter(
                        Model.StoreContact.number==number).first()

                if contact is None:
                    stats.inc_value("contacts")
                    contact = Model.StoreContact(role, name, number)

                store.contacts.append(contact)

            for hour in item['hours']:
                start_day = hour['startDay']
                end_day = hour['endDay']
                start_hour = hour['open']
                end_hour = hour['close']
                summer_hours = hour['summerHours']

                hours = session.query(Model.StoreHours).filter(
                    Model.StoreHours.store_id==store.id).filter(
                    Model.StoreHours.start_day==start_day).filter(
                    Model.StoreHours.end_day==end_day).filter(
                    Model.StoreHours.open==start_hour).filter(
                    Model.StoreHours.close==end_hour).filter(
                    Model.StoreHours.summer_hours==summer_hours).first()

                if hours is None:
                    stats.inc_value("hours")
                    hours = Model.StoreHours(store.id, 
                                             start_day,
                                             end_day,
                                             start_hour,
                                             end_hour,
                                             summer_hours)

                store.hours.append(hours)


        elif t is StoreInventory:
            store = session.query(Model.Store).filter(Model.Store.id==item['store']).first()
            spirit = session.query(Model.Spirit).filter(Model.Spirit.id==item['spirit']).first()

            inv = Model.StoreInventory(store.id, spirit.id)

            inv.qty = item['qty']

            store.inventory.append(inv)
            spirit.inventory.append(inv)

            stats.inc_value("inventory")

        return item

    def nameForSize(self, size):
        s = float(size)

        if s <= .120:
            return 'mini'

        if s > .120 and s <= .240:
            return 'half-pint'

        if s > .240 and s <= .400:
            return 'pint'

        if s > .400 and s <= .650:
            return '500ml'
        
        if s > .650 and s <= .800:
            return 'fifth'

        if s > .800 and s <= 1.130:
            return 'liter'

        if s > 1.130 and s <= 1.800:
            return '1,750ml'

        if s > 1.800:
            return 'jumbo'


class PriceBucketsPipeline(object):
    def __init__(self):
        self.duplicates = {}
        dispatcher.connect(self.spider_opened, signals.spider_opened)
        dispatcher.connect(self.spider_closed, signals.spider_closed)

    def spider_opened(self, spider):
        self.priceBuckets = {}

        self.priceBuckets['global'] = {}
        self.priceBuckets['category'] = {}

    def spider_closed(self, spider):
        # Calculate price ranges
        for size in self.priceBuckets['global']:
            lowPrice = float(self.priceBuckets['global'][size]['lowPrice'])
            highPrice = float(self.priceBuckets['global'][size]['highPrice'])

            priceRange = highPrice - lowPrice
            bucketSize = priceRange * 1/3

            # Update database
            s = text("""UPDATE spirits_bak
                           SET price_tier = 'BOTTOM'
                         WHERE total_retail_price < :low
                           AND size_name = :size""")
            session.bind.execute(s, low=(lowPrice + bucketSize), size=size)

            s = text("""UPDATE spirits_bak
                           SET price_tier = 'MIDDLE'
                         WHERE total_retail_price >= :low
                           AND total_retail_price < :high
                           AND size_name = :size""")
            session.bind.execute(s, 
                                 low=(lowPrice + bucketSize), 
                                 high=(highPrice - bucketSize), 
                                 size=size)

            s = text("""UPDATE spirits_bak
                           SET price_tier = 'TOP'
                         WHERE total_retail_price >= :high
                           AND size_name = :size""")
            session.bind.execute(s, high=(highPrice - bucketSize), size=size)

            for cat in self.priceBuckets['category']:
                for size in self.priceBuckets['global']:
             
                    lowPrice = float(self.priceBuckets['category'][cat][size]['lowPrice'])
                    highPrice = float(self.priceBuckets['category'][cat][size]['highPrice'])
                    priceRange = highPrice - lowPrice
                    bucketSize = priceRange * 1/3

                    s = text("""UPDATE spirits_bak
                                   SET category_price_tier = 'BOTTOM'
                                 WHERE total_retail_price < :low
                                   AND category = :cat
                                   AND size_name = :size""")
                    session.bind.execute(s, 
                                         low=(lowPrice + bucketSize), 
                                         size=size,
                                         cat=cat)

                    s = text("""UPDATE spirits_bak
                                   SET category_price_tier = 'MIDDLE'
                                 WHERE total_retail_price >= :low
                                   AND total_retail_price < :high
                                   AND category = :cat
                                   AND size_name = :size""")
                    session.bind.execute(s, 
                                         low=(lowPrice + bucketSize), 
                                         high=(highPrice - bucketSize), 
                                         size=size,
                                         cat=cat)

                    s = text("""UPDATE spirits_bak
                                   SET category_price_tier = 'TOP'
                                 WHERE total_retail_price >= :high
                                   AND category = :cat
                                   AND size_name = :size""")
                    session.bind.execute(s, 
                                         high=(highPrice - bucketSize), 
                                         size=size,
                                         cat=cat)
                    
    def process_item(self, item, spider):
        t = type(item)
        
        if t is not Spirit:
            return item

        category = item['category']
        size = item['size_name']
        totalRetailPrice = item['totalRetailPrice']

        if size not in self.priceBuckets['global']:
            self.priceBuckets['global'][size] = {}
            self.priceBuckets['global'][size]['lowPrice'] = None
            self.priceBuckets['global'][size]['highPrice'] = None

        if category not in self.priceBuckets['category']:
            self.priceBuckets['category'][category] = {}

        if size not in self.priceBuckets['category'][category]:
            self.priceBuckets['category'][category][size] = {}
            self.priceBuckets['category'][category][size]['lowPrice'] = None
            self.priceBuckets['category'][category][size]['highPrice'] = None

        # Set some variables to shorten my hashs
        lowPrice = self.priceBuckets['global'][size]['lowPrice']
        highPrice = self.priceBuckets['global'][size]['highPrice']

        categoryLowPrice = self.priceBuckets['category'][category][size]['lowPrice']
        categoryHighPrice = self.priceBuckets['category'][category][size]['highPrice']

        if lowPrice is None or totalRetailPrice < lowPrice:
            lowPrice = totalRetailPrice

        if highPrice is None or totalRetailPrice > highPrice:
            highPrice = totalRetailPrice

        if categoryLowPrice is None or totalRetailPrice < categoryLowPrice:
            categoryLowPrice = totalRetailPrice

        if categoryHighPrice is None or totalRetailPrice > categoryHighPrice:
            categoryHighPrice = totalRetailPrice

        self.priceBuckets['global'][size]['lowPrice'] = lowPrice
        self.priceBuckets['global'][size]['highPrice'] = highPrice

        self.priceBuckets['category'][category][size]['lowPrice'] = categoryLowPrice
        self.priceBuckets['category'][category][size]['highPrice'] = categoryHighPrice

        return item


# At completion of crawl toggles the database tables
class ToggleTablesPipeline(object):
    def __init__(self):
        self.duplicates = {}
        dispatcher.connect(self.spider_opened, signals.spider_opened)
        dispatcher.connect(self.spider_closed, signals.spider_closed)

    def spider_opened(self, spider):
        # Truncate backup tables
        session.execute("TRUNCATE TABLE contacts_bak")
        session.execute("TRUNCATE TABLE hours_bak")
        session.execute("TRUNCATE TABLE spirits_bak")
        session.execute("TRUNCATE TABLE store_contacts_bak")
        session.execute("TRUNCATE TABLE store_inventory_bak")
        session.execute("TRUNCATE TABLE stores_bak")
        session.execute("TRUNCATE TABLE distiller_spirits_bak")

    def spider_closed(self, spider):
        distillers = session.query(Model.Distiller).filter(Model.Distiller.search_term!=None)
        for d in distillers.all():

            stats.inc_value("distillers")

            if d.search_term:
                for term in d.search_term.split(','):
                    search_term = '%' + term + '%'

                    # select all spirits that match search_term
                    spirits = session.query(Model.Spirit).filter(Model.Spirit.brand_name.like(search_term))

                    for s in spirits.all():
                        d.spirits.append(s)

        # Check number of items crawled and if ok toggle tables
        #Swap live tables with backups if difference between them is < 5%
        s = text("""select old, new, (abs(new - old)/new)*100 from (select count(*) as new from spirits_bak) as n, (select count(*) as old from spirits) as o""")
        row = session.execute(s).fetchall()
        if row[0][2] < 5 and row[0][1] > 5000:
            stats.inc_value("toggled")
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

    def process_item(self, item, spider):
        return item

class EmailStatsPipeline(object):
    def __init__(self):
        dispatcher.connect(self.spider_opened, signals.spider_opened)
        dispatcher.connect(self.spider_closed, signals.spider_closed)

    def spider_opened(self, spider):
        pass

    def spider_closed(self, spider):
        # Send email with stats

        body = """ Crawling completed.

Crawl Stats:
  page loads: %s
  categegories: %s
  spirits: %s
  stores: %s
  inventory: %s
  hours: %s
  contacts: %s

Duplicates:
  categegories: %s
  spirits: %s
  stores: %s
  inventory: %s

GeoCode:
  stores: %s

Records written:
  Spirits: %s
  Stores: %s
  Contacts: %s
  Hours: %s
  Inventory: %s
  Distillers: %s

Tables Toggled:
  toggled: %s""" % (stats.get_value('page_load'),
                    stats.get_value('categories_crawled'),
                    stats.get_value('spirits_crawled'),
                    stats.get_value('stores_crawled'),
                    stats.get_value('inventory_crawled'),
                    stats.get_value('hours_crawled'),
                    stats.get_value('contacts_crawled'),
                    stats.get_value("categories_dupe"),
                    stats.get_value("spirits_dupe"),
                    stats.get_value("stores_dupe"),
                    stats.get_value("inventory_dupe"),
                    stats.get_value("geocode"),
                    stats.get_value("spirits"),
                    stats.get_value("stores"),
                    stats.get_value("contacts"),
                    stats.get_value("hours"),
                    stats.get_value("inventory"),
                    stats.get_value("distillers"),
                    stats.get_value("toggled"))

        s = text("""SELECT table_name, 
                           table_rows 
                      FROM information_schema.tables 
                     WHERE table_schema = "wsll" 
                       AND table_type = "BASE TABLE";""")
        rows = session.execute(s).fetchall()

        body += " \n\nTable Stats:\n"
        for row in rows:
            body += "  %s: %d\n" % (row[0], row[1])
        
        mailer = MailSender()
        mailer.send(to=["rob@larubbio.org"], subject="Crawl Stats", body=body)
  
        pass

    def process_item(self, item, spider):
        return item

