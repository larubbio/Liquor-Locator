import logging
import unittest
import simplejson as json
import TestUtils

class StoresTestCase(unittest.TestCase):
    def setUp(self):
        # Create a catalog
        self.catalog = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )

        self.url = 'http://localhost:8080/%s/stores' % self.catalog['id']

    def tearDown(self):
        TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id': self.catalog['id']})

#         TestUtils.loadURL(self.url, method='delete', 
#                           params={'id': self.s1['id']})

#         TestUtils.loadURL(self.url, method='delete', 
#                           params={'id': self.s2['id']})

    def testCreateStore(self):
        """Tests creating a valid store"""

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

        response_json = TestUtils.loadURL(self.url, 
                                          method='post', 
                                          params=params)

        assert response_json is not None, "No response"
        assert response_json is not '', "No response"

        s = json.loads( response_json )

        assert 'store_number' in s, 'Missing response key'
        assert s['store_number'] == 8, 'Invalid store number returned'
        assert len(s['hours']) == 2, 'Invalid number of hours'
        assert len(s['contacts']) == 2, 'Invalid number of contacts'
        assert 'BARBARA' in [i['name'] for i in s['contacts']], 'Expected contact not found'

#         params = {'store_type':'State Store',
#                   'retail_sales': 1,
#                   'store_number': 24,
#                   'city': 'ANACORTES',
#                   'address': '1005 COMMERCIAL AVE',
#                   'address2': 'SUITE B',
#                   'zip':'98221-4116',
#                   'hours' : [{'start_day': 'Mon', 
#                               'end_day': 'Sat', 
#                               'open':'10:00',
#                               'close':'7:00',
#                               'summer_hours':False,},
#                              {'start_day': 'Mon', 
#                               'end_day': 'Sat', 
#                               'open':'10:00',
#                               'close':'7:00',
#                               'summer_hours':True,},
#                              ],                            
#                   }
#         self.s2 = json.loads( TestUtils.loadURL(self.url, 
#                                                 method='post',
#                                                 params=params) )

        

if __name__ == "__main__":
    unittest.main()
