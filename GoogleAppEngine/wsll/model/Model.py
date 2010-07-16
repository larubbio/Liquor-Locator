from google.appengine.ext import db

class Contacts(db.Model):
    role = db.StringProperty()
    name = db.StringProperty()
    number = db.PhoneNumberProperty()

class Hours(db.Model):
    start_day = db.StringProperty()
    end_day = db.StringProperty()
    open = db.StringProperty()
    close = db.StringProperty()
    summer_hours = db.BooleanProperty()

class Spirit(db.Model):
    category = db.CategoryProperty(required=True, indexed=True)
    name = db.StringProperty(required=True, indexed=True)
    code = db.IntegerProperty(required=True, indexed=True)
    retail_price = db.FloatProperty(required=True)
    sales_tax = db.FloatProperty(required=True)
    total_retail_price = db.FloatProperty(required=True)
    class_h_price = db.FloatProperty(required=True)
    merchandising_special_note = db.StringProperty(multiline=True)
    size = db.FloatProperty(required=True)
    case_price = db.FloatProperty(required=True)
    proof = db.IntegerProperty()
    liter_cost = db.FloatProperty(required=True)
    on_sale = db.BooleanProperty(indexed=True)
    closeout = db.BooleanProperty(indexed=True)
    
class Store(db.Model):
    store_type = db.StringProperty()
    retail = db.BooleanProperty()
    store_number = db.IntegerProperty(required=True, indexed=True)
    address = db.PostalAddressProperty(required=True)
    location = db.GeoPtProperty(required=True, indexed=True)

    hours = db.ReferenceProperty(reference_class=Hours, collection_name="stores"
    contacts = db.ReferenceProperty(reference_class=Contacts, collection_name='stores')

class StoreInventory(db.Model):
    store = db.ReferenceProperty(reference_class=Store, collection_name='inventory')
    spirit = db.ReferenceProperty(reference_class=Spirit, collection_name="stores")
    quantity = db.IntegerProperty()

