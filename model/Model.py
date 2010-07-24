from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import *
from sqlalchemy.schema import UniqueConstraint

Base = declarative_base()
Session = scoped_session(sessionmaker(autocommit=False,
                                      autoflush=True))

# association table
store_contacts = Table('store_contacts', Base.metadata,
                       Column('store_id', Integer, ForeignKey('stores.id')),
                       Column('contact_id', Integer, ForeignKey('contacts.id'))
                       )

class Store(Base):
    __tablename__ = 'stores'

    id = Column(Integer, primary_key=True)
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
    __tablename__ = 'contacts'

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
    __tablename__ = 'hours'

    id = Column(Integer, primary_key=True)
    store_id = Column(Integer, ForeignKey('stores.id'))
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
    __tablename__ = 'spirits'

    id = Column(String(10), primary_key=True)
    category = Column(String(50))
    brand_name = Column(String(45))
    retail_price = Column(Numeric('10,2'))
    sales_tax = Column(Numeric('10,2'))
    total_retail_price = Column(Numeric('10,2'))
    class_h_price = Column(Numeric('10,2'))
    merchandising_note = Column(UnicodeText)
    size = Column(Numeric('6,4'))
    case_price = Column(Numeric('10,2'))
    liter_cost = Column(Numeric('10,2'))
    proof = Column(Integer)
    on_sale = Column(Boolean)
    closeout = Column(Boolean)

    def __init__(self, id):
        self.id = id
        Session().add(self)

    def __repr__(self):
       return "<Item(%s, '%s')>" % (self.id, self.brand_name)

class StoreInventory(Base):
    __tablename__ = 'store_inventory'

    id = Column(Integer, primary_key=True)
    qty = Column(Integer)
    store_id = Column(Integer, ForeignKey('stores.id'))
    spirit_id = Column(String(10), ForeignKey('spirits.id'))


    store = relationship(Store, backref='inventory')
    spirit = relationship(Spirit, backref='inventory')

    def __init__(self, store_id, spirit_id):
        self.store_id = store_id
        self.spirit_id = spirit_id
        Session().add(self)

    def __repr__(self):
       return "<StoreInventory(%s, %s %s)>" % (self.spirit_id, self.store_id, self.qty)

