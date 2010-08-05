from django.utils import simplejson

from django.db import models

# Create your models here.
class Spirit(models.Model):
    id = models.CharField(max_length=10, primary_key=True)
    category = models.CharField(max_length=50)
    brand_name = models.CharField(max_length=45)
    retail_price = models.DecimalField(max_digits=10, decimal_places=2)
    sales_tax = models.DecimalField(max_digits=10, decimal_places=2)
    total_retail_price = models.DecimalField(max_digits=10, decimal_places=2)
    class_h_price = models.DecimalField(max_digits=10, decimal_places=2)
    merchandising_note = models.TextField()
    size = models.DecimalField(max_digits=5, decimal_places=3)
    case_price = models.DecimalField(max_digits=10, decimal_places=2)
    liter_cost = models.DecimalField(max_digits=10, decimal_places=2)
    proof = models.IntegerField()
    on_sale = models.BooleanField()
    closeout = models.BooleanField()

    def __unicode__(self):
        return "<Spirit: %s '%s'>" % (self.id, self.brand_name)

    def dict(self):
        ret = {'id' : self.id,
               'category' : self.category,
               'brand_name' : self.brand_name,
               'retail_price' : str(self.retail_price),
               'sales_tax' : str(self.sales_tax),
               'price' : str(self.total_retail_price),
               'class_h_price' : str(self.class_h_price),
               'merchandising_note' : self.merchandising_note,
               'size' : str(self.size),
               'case_price' : str(self.case_price),
               'liter_cost' : str(self.liter_cost),
               'proof' : self.proof,
               'on_sale' : self.on_sale,
               'closeout' : self.closeout,
               }

        return ret

    def json(self):
        ret = self.dict()

        return simplejson.dumps(ret)

    class Meta:
        db_table = 'spirits'

class Contact(models.Model):

    role = models.CharField(max_length=45)
    name = models.CharField(max_length=45)
    number = models.CharField(max_length=45)

    def __unicode__(self):
       return "<Contact(%s, '%s %s')>" % (self.id, self.name, self.number)

    def dict(self):
        ret = self.__dict__.copy()
        del ret['_state']

        return ret

    def json(self):
        ret = self.dict()

        return simplejson.dumps(ret)

    class Meta:
        db_table = 'contacts'

class Store(models.Model):
    id = models.IntegerField(primary_key=True)

    name = models.CharField(max_length=45)
    store_type = models.CharField(max_length=45)
    retail_sales = models.BooleanField()
    city = models.CharField(max_length=45)
    address = models.CharField(max_length=45)
    address2 = models.CharField(max_length=45)
    zip = models.CharField(max_length=45)
    lat_rad = models.DecimalField(max_digits=15, decimal_places=12)
    long_rad = models.DecimalField(max_digits=15, decimal_places=12)
    lat = models.DecimalField(max_digits=10, decimal_places=7)
    long = models.DecimalField(max_digits=10, decimal_places=7)

    # many to many
    contacts = models.ManyToManyField(Contact, 
                                      db_table='store_contacts', 
                                      related_name='stores')

    def __unicode__(self):
        return "<Store: %d, '%s'>" % (self.id, self.city)

    def dict(self):
        ret = self.__dict__.copy()
        del ret['_state']
        del ret['lat_rad']
        del ret['long_rad']

        ret['lat'] = str(self.lat)
        ret['long'] = str(self.long)

        ret['hours'] = []
        for h in self.hours.all():
            ret['hours'].append(h.dict())

        ret['contacts'] = []
        for c in self.contacts.all():
            ret['contacts'].append(c.dict())

        return ret

    def json(self):
        ret = self.dict()

        return simplejson.dumps(ret)

    class Meta:
        db_table = 'stores'

class Hours(models.Model):
    store = models.ForeignKey(Store, related_name="hours")
    start_day = models.CharField(max_length=5)
    end_day = models.CharField(max_length=5)
    open = models.CharField(max_length=5)
    close = models.CharField(max_length=5)
    summer_hours = models.BooleanField()
    
    def __unicode__(self):
        return "<Hours: %s - %s, %s - %s>" % (self.start_day, 
                                              self.end_day, 
                                              self.open,
                                              self.close)

    def dict(self):
        ret = self.__dict__.copy()
        del ret['_state']

        return ret

    def json(self):
        ret = self.dict()

        return simplejson.dumps(ret)

    class Meta:
        db_table = 'hours'

class StoreInventory(models.Model):
    store = models.ForeignKey(Store, related_name="inventory")
    spirit = models.ForeignKey(Spirit, related_name="inventory")
    qty = models.IntegerField()

    def __unicode__(self):
        return "<StoreInventory: %s, %s, %d>" % (self.spirit.id, self.store.id, self.qty)

    def dict(self):
        ret = {}

        ret['store'] = self.store.dict()
        ret['spirit'] = self.spirit.dict()
        ret['qty'] = self.qty

        return ret

    def json(self):
        return simplejson.dumps(self.dict())

    class Meta:
        db_table = 'store_inventory'

class Category(models.Model):
    category = models.CharField(max_length=50, primary_key=True)
    
    def __unicode__(self):
        return "<Category: %s>" % (self.category)

    def json(self):
        return simplejson.dumps(self.category)

    class Meta:
        db_table = 'categories_view'
        managed = False
