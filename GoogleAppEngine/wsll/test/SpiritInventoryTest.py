import logging
import unittest
import simplejson as json
import TestUtils

class SpiritTestCase(unittest.TestCase):
    def setUp(self):
        # Create a catalog
        self.catalog = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )

        self.spirits_url = 'http://localhost:8080/%s/spirits' % self.catalog['id']
        self.stores_url = 'http://localhost:8080/%s/stores' % self.catalog['id']

        # Create a spirits
        params = json.dumps({'brand_code': '098154',
                             'category': 'APERITIF',
                             'brand_name': 'LILLET WHITE APERITIF',
                             'retail_price': 13.95,
                             'sales_tax': 0.34,
                             'total_retail_price': 14.29,
                             'class_h_price': 14.29,
                             'merchandising_note': '',
                             'size': 0.750,
                             'case_price': 171.48,
                             'liter_cost': 19.05,
                             'proof': 17,
                             'on_sale': 0,
                             'closeout': 0,
                             })

        response_json = TestUtils.loadURL(self.spirits_url, 
                                          method='post', 
                                          params=params)

        self.spirit = json.loads( response_json )

        params = json.dumps({'store_type':'State Store',
                             'retail_sales': 1,
                             'store_number': 8,
                             'city': 'ABERDEEN',
                             'address': '216 W HERON ST',
                             'address2': None,
                             'zip':'98520-6225',
                             'hours' : [{'start_day': 'Mon', 
                                         'end_day': 'Sat', 
                                         'open':'11:00',
                                         'close':'8:00',
                                         'summer_hours':False,},
                                        {'start_day': 'Sun', 
                                         'end_day': 'Sun', 
                                         'open':'12:00',
                                         'close':'5:00',
                                         'summer_hours':False,},
                                        ],
                             'contacts' : [{'role':'Store Manager',
                                            'name': 'BARBARA',
                                            'number': '360-533-9311',},
                                           {'role': 'Distric Manager',
                                            'name': 'KATHE MCDANIEL',
                                            'number': '360-664-1621',}
                                           ],
                             })

        response_json = TestUtils.loadURL(self.stores_url, 
                                          method='post', 
                                          params=params)

        self.store = json.loads( response_json )

        self.url = 'http://localhost:8080/%s/spirit/%s/stores' % (self.catalog['id'],
                                                                  self.spirit['brand_code'])
        

    def tearDown(self):
        TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id': self.catalog['id']})


    def testAddSpiritInventory(self):
        """Tests adding inventory for a spirit"""

        params = json.dumps({'store_id': self.store['store_number'],
                             'quantity': 11,})

        response_json = TestUtils.loadURL(self.url, 
                                          method='post', 
                                          params=params)

        import pdb; pdb.set_trace()
        assert response_json is not None, "No response"
        assert response_json is not '', "No response"

        s = json.loads( response_json )

        assert s == self.spirit, 'Response does not match expected values'

if __name__ == "__main__":
    unittest.main()
