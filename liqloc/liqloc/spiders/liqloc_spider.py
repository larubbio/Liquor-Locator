import re
from scrapy import log

from scrapy.spider import BaseSpider
from scrapy.http import FormRequest
from scrapy.selector import HtmlXPathSelector
from scrapy.stats import stats

from liqloc.items import Category
from liqloc.items import Spirit
from liqloc.items import Store
from liqloc.items import StoreContact
from liqloc.items import StoreHours
from liqloc.items import StoreInventory

class LiqLocSpider(BaseSpider):
    name = "liq.wa.gov"
    allowed_domains = ["liq.wa.gov", "localhost"]
    start_urls = [
        "http://liq.wa.gov/LCBhomenet/StoreInformation/BrandSearch.aspx"
    ]

    def parse(self, response):
        stats.inc_value('page_load')

        hxs = HtmlXPathSelector(response)
        viewState = hxs.select('//input[@id="__VIEWSTATE"]/@value').extract()
        eventValidation = hxs.select('//input[@id="__EVENTVALIDATION"]/@value').extract()
        for f in hxs.select('//option/@value').extract():
            idCatBrand = f
            category = Category()
            category['name'] = f.strip()

            request = FormRequest.from_response(response, 
                                                formname="form1", 
                                                clickdata={'id':'Button3','name':'Button3'},
                                                callback=self.parse_category,
                                                formdata={'IDCatBrand' : idCatBrand})

            request.meta['category'] = category['name']

            stats.inc_value('categories_crawled')
            yield request

    def parse_category(self, response):
        stats.inc_value('page_load')

        log.msg("Parsing %s" % response.request.meta['category'], log.INFO)

        hxs = HtmlXPathSelector(response)
        table = hxs.select('//table')[0]

        # Ignore the header row
        rows = table.select('tr')[1:]

        for row in rows:
            columns = row.select('td')
            
            spirit = Spirit()

            spirit['code'] = columns[0].select('text()').extract()[0]
            spirit['name'] = columns[1].select('text()').extract()[0]
            spirit['retailPrice'] = columns[2].select('text()').extract()[0]
            spirit['salesTax'] = columns[3].select('text()').extract()[0]
            spirit['totalRetailPrice'] = columns[4].select('text()').extract()[0]
            spirit['classHPrice'] = columns[5].select('text()').extract()[0]
            spirit['casePrice'] = columns[6].select('text()').extract()[0]
            spirit['size'] = columns[7].select('text()').extract()[0]
            spirit['proof'] = columns[8].select('text()').extract()[0]
            spirit['literCost'] = columns[9].select('text()').extract()[0]
            spirit['merchandisingSpecialNotes'] = columns[10].select('text()').extract()[0]
            spirit['category'] = response.request.meta['category']

            stats.inc_value('spirits_crawled')
            yield spirit

            value = columns[11].select('a/@href').extract()
            m = re.search("javascript:__doPostBack\('(.*?)','(.*?)'", str(value))

            request = FormRequest.from_response(response, 
                                                formname="form1", 
                                                callback=self.parse_store,
                                                dont_click=True,
                                                formdata={'__EVENTTARGET' : m.group(1),
                                                          '__EVENTARGUMENT' : m.group(2)})

            request.meta['spirit-code'] = spirit['code']
            request.meta['spirit-name'] = spirit['name']

            yield request
            
    def parse_store(self, response):
        stats.inc_value('page_load')

        log.msg("Parsing stores for %s" % response.request.meta['spirit-name'], log.INFO)

        hxs = HtmlXPathSelector(response)
        table = hxs.select('//table')[0]

        # Ignore the header row
        rows = table.select('tr')[1:]

        for row in rows:
            columns = row.select('td')

            number = columns[0].select('span/text()')[1].re('Store # (.*)')[0]
            
            if stats.get_value('store-%s' % number) is None:
                stats.set_value('store-%s' % number, True)

                store = Store()

                store['name'] = columns[1].select('span/text()')[0].extract()
                store['number'] = number

                # Need to take from same line as zip field
                store['city'] = columns[0].select('span/text()')[0].extract()
                store['address'] = columns[1].select('span/text()')[1].extract()
            #    store['address2'] = Field() 
                store['zip'] = columns[1].select('span/text()')[2].extract().split()[-1]
            
                #            storeType = Field()
                #            retailSales = Field() 

                contacts = []
                contacts.append(self.parseContact(columns[1].select('span/text()')[3:5].extract()))
                contacts.append(self.parseContact(columns[1].select('span/text()')[5:7].extract()))
                store['contacts'] = contacts

                hours = self.parseHours(store, 
                                        columns[2].select('span/text()').extract())

                summerHours = self.parseHours(store, 
                                              columns[3].select('span/text()').extract(), 
                                              summer=True)

                store['hours'] = hours + summerHours

                stats.inc_value('stores_crawled')
                yield store

            si = StoreInventory()
            si['store'] = number
            si['qty'] = columns[4].select('span/text()')[1].re('([0-9]*)$')[0]
            si['spirit'] = response.request.meta['spirit-code']

            stats.inc_value('inventory_crawled')
            yield si

    def parseHours(self, store, spans, summer=False):
        ret = []
        for s in spans:
            # If the store is closed on a day ignore it
            if not 'Closed' in s:
                (day, hours) = s.split()
                (open, close) = hours.split('-')

                h = StoreHours()
                h['store'] = store['number']
                h['startDay'] = day
                h['endDay'] = day
                h['open'] = open
                h['close'] = close
                h['summerHours'] = summer
            
                stats.inc_value('hours_crawled')
                ret.append(h)

        return ret
     
    def parseContact(self, spans):
        sc = StoreContact()

        sc['role'] = spans[0].strip()

        m = re.search('(.*).*(\(...\) ........)', str(spans[1]))
        sc['name'] = m.group(1).strip()
        sc['number'] = m.group(2)

        stats.inc_value('contacts_crawled')
        return sc

