import logging
import unittest
import simplejson as json
import TestUtils

class CatalogTestCase(unittest.TestCase):
    def setUp(self):
        # Create two catalogs
        self.c1 = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )
        self.c2 = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )


    def tearDown(self):
        TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id': self.c1['id']})
        TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id': self.c2['id']})

    def testGetAllCatalogs(self):
        """Check that load all catalogs loads at least the two we created"""

        catalogs = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs') )

        ids = [c['id'] for c in catalogs]

        assert self.c1['id'] in ids, 'Failed to load all catalogs'
        assert self.c2['id'] in ids, 'Failed to load all catalogs'
        assert len(catalogs) >= 2, 'Failed to load all catalogs'

    def testGetCurrentCatalog(self):
        """Check that current only loads the current catalog"""

        catalogs = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='get', params={'current':1}) )

        ids = [c['id'] for c in catalogs]

        assert self.c1['id'] not in ids, 'Non-newest catalog loaded'
        assert self.c2['id'] in ids, 'Failed to load newest catalogs'
        assert len(catalogs) == 1, 'Loaded more than one catalog'      

    def testDeleteCatalog(self):
        """Verify we can delete a catalog"""

        c = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )

        msg = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id': c['id']}) )

        assert msg['status'] == 'success', 'Error deleting catalog'

    def testInvalidDeleteCatalog(self):
        """Verify delete checks it's args"""

        c = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='post') )

        msg = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='delete' ) )

        assert msg['status'] == 'error', 'Error deleting catalog'

        msg = json.loads( TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id':'foo'} ) )

        assert msg['status'] == 'error', 'Error deleting catalog'

        TestUtils.loadURL('http://localhost:8080/catalogs', method='delete', params={'id':c['id']} )
        

if __name__ == "__main__":
    unittest.main()
