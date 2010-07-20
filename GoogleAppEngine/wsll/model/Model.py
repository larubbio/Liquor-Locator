from google.appengine.ext import db

class Catalog(db.Model):
    created_date = db.DateProperty()
    status = db.StringProperty()

    def to_dict(self):
        return {
                'id': self.key().id(),
                'created_date': unicode(self.created_date),
                'status': self.status,
                }

class Spirit(db.Model):
    cid = db.IntegerProperty(required=True)
    category = db.CategoryProperty(required=True, indexed=True)
    brand_name = db.StringProperty(required=True, indexed=True)
    brand_code = db.StringProperty(required=True, indexed=True)
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

    def to_dict(self):
        return {
                'id': self.key().id(),
                'category': self.category,
                'brand_name': self.brand_name,
                'brand_code': self.brand_code,
                'retail_price': self.retail_price,
                'sales_tax': self.sales_tax,
                'total_retail_price': self.total_retail_price,
                'class_h_price': self.class_h_price,
                'merchandising_special_note': self.merchandising_special_note,
                'size': self.size,
                'case_price': self.case_price,
                'proof': self.proof,
                'liter_cost': self.liter_cost,
                'on_sale': self.on_sale,
                'closeout': self.closeout,
                }
    
class Store(db.Model):
    cid = db.IntegerProperty(required=True)
    store_type = db.StringProperty()
    retail = db.BooleanProperty()
    store_number = db.IntegerProperty(required=True, indexed=True)
    address = db.PostalAddressProperty(required=True)
    location = db.GeoPtProperty(indexed=True)

    @property
    def contacts(self):
        return Contact.gql("WHERE stores = :1", self.key())

    def to_dict(self):
        hours = []
        contacts = []

        for h in self.hours:
            hours.append(h.to_dict())

        for c in self.contacts:
            contacts.append(c.to_dict())
        
        return {
                'id': self.key().id(),
                'store_type': self.store_type,
                'retail': self.retail,
                'store_number': self.store_number,
                'address': self.address,
                'location': self.location,
                'hours' : hours,
                'contacts' : contacts,
                }

class Contact(db.Model):
    cid = db.IntegerProperty(required=True)
    role = db.StringProperty()
    name = db.StringProperty()
    number = db.PhoneNumberProperty()

    # Group affiliation
    stores = db.ListProperty(db.Key)

    def to_dict(self):
        return {
                'role': self.role,
                'name': self.name,
                'number': self.number,
                }

class Hours(db.Model):
    cid = db.IntegerProperty(required=True)
    start_day = db.StringProperty()
    end_day = db.StringProperty()
    open = db.StringProperty()
    close = db.StringProperty()
    summer_hours = db.BooleanProperty()

    store = db.ReferenceProperty(Store, collection_name="hours")

    def to_dict(self):
        return {
                'id': self.key().id(),
                'start_day': self.start_day,
                'end_day': self.end_day,
                'open': self.open,
                'close': self.close,
                'summer_hours': self.summer_hours,
                }

class StoreInventory(db.Model):
    cid = db.IntegerProperty(required=True)
    store = db.ReferenceProperty(reference_class=Store, collection_name='inventory')
    spirit = db.ReferenceProperty(reference_class=Spirit, collection_name="inventory")
    quantity = db.IntegerProperty()

    def to_dict(self):
        return {
                'id': self.key().id(),
                'quantity': self.quantity,
                }

class Category(db.Model):
    cid = db.IntegerProperty(required=True)
    name = db.StringProperty(required=True)

    def to_dict(self):
        return {
                'name': self.name,
                }
