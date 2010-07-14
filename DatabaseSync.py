import logging
import mechanize
import re
import sys

from BeautifulSoup import BeautifulSoup

from sqlalchemy import create_engine
from model import Model

LOG_FILENAME = 'output.log'
logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)

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
    city = cols[0].decodeContents()[:cols[0].decodeContents().find(' <br')]

    # Name
    city = cols[1].contents[0]

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

    store.store_type = store_type
    store.retail_sales = retail
    store.city = city
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
    special_note = columns[6].findChild().decodeContents()

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

    # For each click 'Find Store'
    br.select_form(name="DetailForm")
        
    bc = br.form.find_control('brandcode')
    bc.readonly = False
    bc.value = brand_code
    
    spirit_inventory_page = br.submit()
    page = BeautifulSoup(spirit_inventory_page.read())

    table = page.findAll('table')[3]
    rows = table.findAll('tr')[1:]

    for row in rows:
        processStoreAndSpiritInventory(spirit, row)   

    br.back()

engine = create_engine('mysql://wsll:wsll@localhost/wsll', echo=False)

Model.Session.configure(bind=engine)
session = Model.Session()

metadata = Model.Base.metadata
metadata.create_all(engine) 

br = mechanize.Browser()

# Log information about HTTP redirects and Refreshes.
br.set_debug_redirects(True)
# Log HTTP response bodies (ie. the HTML, most of the time).
#br.set_debug_responses(True)
# Print HTTP headers.
br.set_debug_http(True)

# To make sure you're seeing all debug output:
logger = logging.getLogger("mechanize")
logger.addHandler(logging.StreamHandler(sys.stdout))
logger.setLevel(logging.DEBUG)

br.open("http://liq.wa.gov/pricebook/pricebookmenu1.asp")

# follow second link with element text matching regular expression
resp = br.follow_link(text_regex=r"Product Availability")

br.select_form(name="frmBrandSearch")
control = br.form.find_control("CatBrand")
categories = [i.name for i in control.items]
categories.remove("VALUE")

#categories = ['APERITIF', 'VODKA']
for c in categories:
    print c
    br.select_form(name="frmBrandSearch")
    br["CatBrand"] = [c]
    cat_page = br.submit()

    # Parse the page 
    page = BeautifulSoup(cat_page.read())

    # Loop over each row storing spirit information
    table = page('table')[4]
    rows = table.findAll('tr')[1:]
    for row in rows:
        processSpirit(c, row)
        print ".",

    print
    br.back()

session.commit()
