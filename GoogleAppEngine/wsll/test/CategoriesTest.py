import logging
import unittest
import simplejson as json
import TestUtils

class CategoriesTestCase(unittest.TestCase):
    def setUp(self):
        # Create a catalog
        self.catalog = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )

        self.spirit_url = 'http://localhost:8080/%s/spirits' % self.catalog['id']
        self.url = 'http://localhost:8080/%s/categories' % self.catalog['id']

        # Create two spirits
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

        TestUtils.loadURL(self.spirit_url, 
                          method='post', 
                          params=params)
        
        params = json.dumps({'brand_code': '098155',
                             'category': 'GIN',
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

        TestUtils.loadURL(self.spirit_url, 
                          method='post', 
                          params=params)


    def tearDown(self):
        TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id': self.catalog['id']})

    def testGetCategoriesCreateStore(self):
        """Tests loading all categories"""

        # Create a third item in an existing category
        params = json.dumps({'brand_code': '098156',
                             'category': 'GIN',
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

        TestUtils.loadURL(self.url, 
                          method='post', 
                          params=params)
        

        response_json = TestUtils.loadURL(self.url)
        
        assert response_json is not None, "No response"
        assert response_json is not '', "No response"

        categories = json.loads(response_json)
        names = [c['name'] for c in categories]

        assert len(names) == 2, 'Incorrect number of categories returned'
        assert 'GIN' in names, 'Missing GIN category'
        assert 'APERITIF' in names, 'Missing APERITIF category'
        
if __name__ == "__main__":
    unittest.main()
