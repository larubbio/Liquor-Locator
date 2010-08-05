import math
from models import Spirit, Store, StoreInventory, Contact, Hours, Category

from django.db import connection
from django.template import Context, loader
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404, get_list_or_404

from django.utils import simplejson

def spirits(request):
    spirits = []
    rows = []
    data = []

    if 'id' in request.GET:
        spirits = get_list_or_404(Spirit, 
                                  pk=request.GET['id'])
    elif 'name' in request.GET:
        spirits = get_list_or_404(Spirit,
                                  brand_name=request.GET['name'])
    elif 'category' in request.GET:
        spirits = get_list_or_404(Spirit.objects.order_by('brand_name'), 
                                  category=request.GET['category'])
    elif 'search' in request.GET:
        cursor = connection.cursor()

        cursor.execute("select brand_name, count(*), id from spirits where brand_name like '%%" + request.GET['search'] + "%%' group by brand_name order by brand_name")
        
        rows = cursor.fetchall()
    else:
        cursor = connection.cursor()

        cursor.execute("select brand_name, count(*), id from spirits group by brand_name order by brand_name")
        
        rows = cursor.fetchall()

    # If spirits has data I want the fuller json dict
    if len(spirits):
        for s in spirits:
            sd = s.dict()
            data.append({'brand_name': sd['brand_name'], 
                         'id': sd['id'],
                         'size': sd['size'],
                         'price': sd['price']})

    # If rows has data I need the more compressed json dict
    if len(rows):
        for row in rows:
            info = {'n': row[0]}
            if row[1] == 1:
                info['id'] = row[2]
            else:
                info['c'] = row[1]

            data.append(info)

    mimetype = 'application/json'
    return HttpResponse(simplejson.dumps(data),mimetype)

def spirit_inventory(request, spirit_id):
    spirit = get_object_or_404(Spirit, pk=spirit_id)

    ret = []
    for si in spirit.inventory.all():
        store = si.store.dict()
        del store['hours']
        del store['contacts']

        ret.append({'qty':si.qty, 'store':store})

    mimetype = 'application/json'
    return HttpResponse(simplejson.dumps(ret),mimetype)

def spirit(request, spirit_id):
    spirit = get_object_or_404(Spirit, pk=spirit_id)

    mimetype = 'application/json'
    return HttpResponse(spirit.json(),mimetype)

def stores(request):
    stores = []

    if 'id' in request.GET:
        stores = get_list_or_404(Store, pk=request.GET['id'])
    elif 'brand_code' in request.GET:
        spirit = get_object_or_404(Spirit, pk=request.GET['brand_code'])

        stores = spirit.inventory.all().order_by('name')
    elif 'lat' in request.GET and 'long' in request.GET and 'dist' in request.GET:
        # Convert to radians
        lat = math.pi * float(request.GET['lat']) / 180
        long = math.pi * float(request.GET['long']) / 180

        # Convert to kilometers
        dist = 1.609344 * float(request.GET['dist'])
       
        stores = Store.objects.raw('SELECT * FROM stores WHERE acos(sin(%s) * sin(lat_rad) + cos(%s) * cos(lat_rad) * cos(long_rad - (%s))) * 6371 <= %s;' % (lat, lat, long, dist))
    else:
        stores = Store.objects.all().order_by('name')

    data = [s.dict() for s in stores]

    mimetype = 'application/json'
    return HttpResponse(simplejson.dumps(data),mimetype)

def store(request, store_id):
    store = get_object_or_404(Store, pk=store_id)

    mimetype = 'application/json'
    return HttpResponse(store.json(),mimetype)

def store_inventory(request, store_id):
    store = get_object_or_404(Store, pk=store_id)

    ret = []
    for si in store.inventory.all().order_by('brand_name'):
        ret.append({'qty':si.qty, 
                    'spirit_id': si.spirit.id,
                    'brand_name': si.spirit.brand_name})

    mimetype = 'application/json'
    return HttpResponse(simplejson.dumps(ret),mimetype)

def categories(request):
    mimetype = 'application/json'
    data = simplejson.dumps([c.category for c in Category.objects.all()])
    return HttpResponse(data,mimetype)
