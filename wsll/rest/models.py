import datetime
from django.utils import simplejson

from django.db import models

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
    size_name = models.CharField(max_length=25)
    case_price = models.DecimalField(max_digits=10, decimal_places=2)
    liter_cost = models.DecimalField(max_digits=10, decimal_places=2)
    proof = models.IntegerField()
    on_sale = models.BooleanField()
    closeout = models.BooleanField()
    new_item = models.BooleanField()
    one_time_only = models.BooleanField()
    gift_item = models.BooleanField()
    part_case = models.BooleanField()

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

    def dict(self, children=False, hoursByDay=False):
        ret = self.__dict__.copy()
        del ret['_state']
        del ret['lat_rad']
        del ret['long_rad']

        ret['lat'] = str(self.lat)
        ret['long'] = str(self.long)

        if children:
            # I want to handle summer hours here.  Some, but not all stores 
            # have them.
            # Summer Hours: Begin on the Monday of the May 15 week. 
            #               End on the Saturday of the September 15 week
            in_summer_hours = False

            today = datetime.date.today()
            # First see if we are within the month range
            if today.month >= 5 and today.month <= 9:
                # Start off assuming we are in summer hours
                in_summer_hours = True

                # This is the calendar matrix I'm working off of
                #  M  T  W  T  F  S  S - Calendar Day
                #  0  1  2  3  4  5  6 - today.weekday()
                # 15 16 17 18 19 20 21
                # 14 15 16 
                # 13 14 15 16
                #    13 14 15
                #             15
                #                15
                #  9                15
                start_day = 15 - (6 - today.weekday())
                end_day = start_day + 6

                # If we are in may but before the mon. of the week of the 15th
                if today.month == 5:
                    if today.day < start_day:
                        in_summer_hours = False

                # If we are in sep. but after the sat of the week of the 15th
                if today.month == 9:
                    if today.day > end_day:
                        in_summer_hours = False

            if in_summer_hours:
                # Get just the summer hours
                _hours = self.hours.all().filter(summer_hours=1)
                if len(_hours) == 0:
                    # This store doesn't have different summer hours
                    _hours = self.hours.all()
            else:
                _hours = self.hours.all()

            ret['hours'] = []
            if hoursByDay:
                for d in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]:
                    _days = [days for days in _hours if d == days.start_day]
                    if len(_days) > 0:
                        ret['hours'].append(_days[0].dict())
                    else:
                        ret['hours'].append({'start_day': d,
                                             'end_day': d,
                                             'store_id': self.id, 
                                             'close': None, 'open' : None})
            else:
                # We need to rebuild the old style of hours where
                # consecutive days with the same hours are rolled up
                startDay = "Mon"
                endDay = "Mon"
                cur = [days for days in _hours if 'Mon' == days.start_day][0].dict()

                for d in ["Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]:

                    _days = [days for days in _hours if d == days.start_day]
                    if len(_days) > 0:
                        day = _days[0].dict()

                        if cur['open'] == day['open'] and cur['close'] == day['close']:
                            endDay = d
                        else:
                            # Todays hours are different from yesterdays so 
                            # output the previous hours and set variables
                            ret['hours'].append({'start_day': startDay, 
                                                 'store_id': cur['store_id'], 
                                                 'end_day': endDay, 
                                                 'close': cur['close'],
                                                 'open': cur['open']})
                            startDay = d
                            endDay = d

                        cur = day

                    else:
                        # The day I'm looking for isn't in the hash
                        ret['hours'].append({'start_day': startDay, 
                                             'store_id': cur['store_id'], 
                                             'end_day': endDay, 
                                             'close': cur['close'], 
                                             'open': cur['open']})

                        # If I am on Sun then don't reset the data
                        # The old system just left Sun off if the store was
                        # closed
                        if 'Sun' != d:
                            startDay = d
                            endDay = d
                            cur = {'store_id': cur['store_id'], 
                                   'close': None, 'open' : None}

                    # If this is Sun we need to output since we are at the 
                    # end of the week
                    if 'Sun' == d and startDay == endDay and 'Sun' == startDay:
                        ret['hours'].append({'start_day': startDay, 
                                             'store_id': cur['store_id'], 
                                             'end_day': endDay, 
                                             'close': cur['close'], 
                                             'open': cur['open']})
               

            ret['contacts'] = []
            for c in self.contacts.all():
                ret['contacts'].append(c.dict())

        return ret

    def json(self, hoursByDay=False):
        ret = self.dict(children=True, hoursByDay=hoursByDay)

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
        del ret['summer_hours']

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

class Distiller(models.Model):
    id = models.IntegerField(primary_key=True)

    name = models.CharField(max_length=45)
    street = models.CharField(max_length=45)
    address = models.CharField(max_length=45)
    lat = models.DecimalField(max_digits=10, decimal_places=7)
    long = models.DecimalField(max_digits=10, decimal_places=7)
    url = models.CharField(max_length=255)
    search_term = models.CharField(max_length=45)

    # many to many
    spirits = models.ManyToManyField(Spirit, 
                                     db_table='distiller_spirits', 
                                     related_name='distiller')

    def __unicode__(self):
        return "<Distiller: %d, '%s'>" % (self.id, self.name)

    def dict(self):
        ret = self.__dict__.copy()
        del ret['_state']

        ret['lat'] = str(self.lat)
        ret['long'] = str(self.long)

        ret['spirits'] = []
        for s in self.spirits.all():
            ret['spirits'].append(s.dict())
        
        return ret

    def json(self):
        ret = self.dict()

        return simplejson.dumps(ret)

    class Meta:
        db_table = 'local_distillers'

