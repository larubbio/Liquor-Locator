import logging
import urllib,urllib2

def loadURL(url, method='get', params=None):
    logging.info("%s %s (%s)" % (method, url, params))
    data = None
    json = None

    if params:
        data = urllib.urlencode(params) 

    if data:
        if method in ['get', 'delete']:
            request = urllib2.Request('%s?%s' % (url, data))

        if method in ['post', 'put']:
            request = urllib2.Request(url, data=data)

    else:
        request = urllib2.Request(url)
        
    request.get_method = lambda: method.upper()

    try:
        response = urllib2.urlopen(request)
        json = response.read()
    except urllib2.HTTPError, e:
        json = e.read()

    return json

