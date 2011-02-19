# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/topics/items.html

from scrapy.item import Item, Field

class Category(Item):
    name = Field()

class Store(Item):
    name = Field()
    number = Field()
#    storeType = Field()
#    retailSales = Field() 
    city = Field() 
    address = Field() 
    address2 = Field(default=None) 
    zip = Field() 
    latRad = Field() 
    longRad = Field() 
    lat = Field() 
    long = Field() 
    contacts = Field()
    hours = Field()

class StoreContact(Item):
    role = Field()
    name = Field()
    number = Field()

class StoreHours(Item):
    store = Field()
    startDay = Field()
    endDay = Field()
    open = Field()
    close = Field()
    summerHours = Field()

class StoreInventory(Item):
    store = Field()
    qty = Field()
    spirit = Field()

class Spirit(Item):
    code = Field()
    name = Field()
    retailPrice = Field()
    salesTax = Field()
    totalRetailPrice = Field()
    classHPrice = Field()
    casePrice = Field()
    size = Field()
    proof = Field()
    literCost = Field()
    merchandisingSpecialNotes = Field()
    on_sale = Field(default=False)
    closeout = Field(default=False)
    new_item = Field(default=False)
    one_time_only = Field(default=False)
    gift_item = Field(default=False)
    part_case = Field(default=False)
    category = Field()
