from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import *
from sqlalchemy.schema import UniqueConstraint

Base = declarative_base()
Session = scoped_session(sessionmaker(autocommit=False,
                                      autoflush=True))

# association table
store_contacts = Table('store_contacts_bak', Base.metadata,
                       Column('store_id', Integer, ForeignKey('stores_bak.id')),
                       Column('contact_id', Integer, ForeignKey('contacts_bak.id'))
                       )

distiller_spirits = Table('distiller_spirits_bak', Base.metadata,
                       Column('distiller_id', Integer, ForeignKey('local_distillers_bak.id')),
                       Column('spirit_id', Integer, ForeignKey('spirits_bak.id'))
                       )

class Distiller(Base):
    __tablename__ = 'local_distillers_bak'

    id = Column(Integer, primary_key=True)
    name = Column(String(45))
    street = Column(String(45))
    address = Column(String(45))
    lat = Column(Numeric('10,7'))
    long = Column(Numeric('10,7'))
    url = Column(String(255))
    search_term = Column(String(45))
    
    # many to many Distiller<->Spirits
    # While this is many to many it is actually just one to many, I just don't want
    # distiller_id in the spirits table
    spirits = relationship('Spirit', secondary=distiller_spirits, backref='distiller')

    def __init__(self, name, street, address, lat, long, url, search_term):
        self.name = name
        self.street = street
        self.address = address
        self.lat = lat
        self.long = long
        self.url = url
        self.search_term = search_term
        Session().add(self)    

    def __repr__(self):
       return "<Distiller(%s, '%s')>" % (self.id, self.name)

class Store(Base):
    __tablename__ = 'stores_bak'

    id = Column(Integer, primary_key=True)
    name = Column(String(45))
    store_type = Column(String(45))
    retail_sales = Column(Boolean)
    city = Column(String(45))
    address = Column(String(45))
    address2 = Column(String(45))
    zip = Column(String(45))
    lat_rad = Column(Numeric('12,11'))
    long_rad = Column(Numeric('12,11'))
    lat = Column(Numeric('10,7'))
    long = Column(Numeric('10,7'))
    
    # many to many Stores<->Contacts
    contacts = relationship('StoreContact', secondary=store_contacts, backref='stores')

    def __init__(self, id):
        self.id = id
        Session().add(self)    

    def __repr__(self):
       return "<Store(%s, '%s')>" % (self.id, self.city)

class StoreContact(Base):
    __tablename__ = 'contacts_bak'

    id = Column(Integer, primary_key=True)
    role = Column(String(45))
    name = Column(String(45))
    number = Column(String(45))

    def __init__(self, role, name, number):
        self.role = role
        self.name = name
        self.number = number
        Session().add(self)    

    def __repr__(self):
       return "<Contact(%s, '%s')>" % (self.id, self.name)

class StoreHours(Base):
    __tablename__ = 'hours_bak'

    id = Column(Integer, primary_key=True)
    store_id = Column(Integer, ForeignKey('stores_bak.id'))
    start_day = Column(String(5))
    end_day = Column(String(5))
    open = Column(String(5))
    close = Column(String(5))
    summer_hours = Column(Boolean)

    store = relationship(Store, backref='hours')

    def __init__(self, store_id, start_day, end_day, open, close, summer_hours):
        self.store_id = store_id
        self.start_day = start_day
        self.end_day = end_day
        self.open = open
        self.close = close
        self.summer_hours = summer_hours
        Session().add(self)    

    def __repr__(self):
       return "<Hours('%s - %s %s - %s')>" % (self.start_day, self.end_day, self.open, self.close)

class Spirit(Base):
    __tablename__ = 'spirits_bak'

    id = Column(String(10), primary_key=True)
    category = Column(String(50))
    brand_name = Column(String(45))
    retail_price = Column(Numeric('10,2'))
    sales_tax = Column(Numeric('10,2'))
    total_retail_price = Column(Numeric('10,2'))
    class_h_price = Column(Numeric('10,2'))
    merchandising_note = Column(UnicodeText)
    size = Column(Numeric('6,4'))
    size_name = Column(String(25))
    case_price = Column(Numeric('10,2'))
    liter_cost = Column(Numeric('10,2'))
    proof = Column(Integer)
    on_sale = Column(Boolean)
    closeout = Column(Boolean)
    new_item = Column(Boolean)
    one_time_only = Column(Boolean)
    gift_item = Column(Boolean)
    part_case = Column(Boolean)

    def __init__(self, id):
        self.id = id
        Session().add(self)

    def __repr__(self):
       return "<Item(%s, '%s')>" % (self.id, self.brand_name)

class StoreInventory(Base):
    __tablename__ = 'store_inventory_bak'

    id = Column(Integer, primary_key=True)
    qty = Column(Integer)
    store_id = Column(Integer, ForeignKey('stores_bak.id'))
    spirit_id = Column(String(10), ForeignKey('spirits_bak.id'))

    store = relationship(Store, backref='inventory')
    spirit = relationship(Spirit, backref='inventory')

    def __init__(self, store_id, spirit_id):
        self.store_id = store_id
        self.spirit_id = spirit_id
        Session().add(self)

    def __repr__(self):
       return "<StoreInventory(%s, %s %s)>" % (self.spirit_id, self.store_id, self.qty)

