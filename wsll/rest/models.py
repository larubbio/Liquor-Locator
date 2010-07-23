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

    class Meta:
        db_table = 'spirits'

class Contact(models.Model):

    role = models.CharField(max_length=45)
    name = models.CharField(max_length=45)
    number = models.CharField(max_length=45)

    def __unicode__(self):
       return "<Contact(%s, '%s %s')>" % (self.id, self.name, self.number)

    class Meta:
        db_table = 'contacts'

class Store(models.Model):
    id = models.IntegerField(primary_key=True)

    store_type = models.CharField(max_length=45)
    retail_sales = models.BooleanField()
    city = models.CharField(max_length=45)
    address = models.CharField(max_length=45)
    address2 = models.CharField(max_length=45)
    zip = models.CharField(max_length=45)

    # many to many
    contacts = models.ManyToManyField(Contact, 
                                      db_table='store_contacts', 
                                      related_name='stores')

    def __unicode__(self):
        return "<Store: %d, '%s'>" % (self.id, self.city)

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

    class Meta:
        db_table = 'hours'

class StoreInventory(models.Model):
    store = models.ForeignKey(Store, related_name="inventory")
    spirit = models.ForeignKey(Spirit, related_name="inventory")
    qty = models.IntegerField()

    def __unicode__(self):
        return "<StoreInventory: %s, %s, %d>" % (self.spirit.id, self.store.id, self.qty)

    class Meta:
        db_table = 'store_inventory'

class Category(models.Model):
    category = models.CharField(max_length=50, primary_key=True)
    
    def __unicode__(self):
        return "<Category: %s>" % (self.category)

    class Meta:
        db_table = 'categories_view'
        managed = False
