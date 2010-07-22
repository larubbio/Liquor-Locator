import logging
import unittest
import simplejson as json
import TestUtils

class SpiritTestCase(unittest.TestCase):
    def setUp(self):
        # Create a catalog
        self.catalog = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )

        self.spirit_url = 'http://localhost:8080/%s/spirits' % self.catalog['id']

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

        response_json = TestUtils.loadURL(self.spirit_url, 
                                          method='post', 
                                          params=params)

        self.spirit = json.loads( response_json )
        self.url = 'http://localhost:8080/%s/spirit/%s' % (self.catalog['id'],
                                                           self.spirit['brand_code'])
        

    def tearDown(self):
        TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id': self.catalog['id']})


    def testGetSpirit(self):
        """Tests loading a valid spirit"""

        response_json = TestUtils.loadURL(self.url)

        assert response_json is not None, "No response"
        assert response_json is not '', "No response"

        s = json.loads( response_json )

        assert s == self.spirit, 'Response does not match expected values'

if __name__ == "__main__":
    unittest.main()
