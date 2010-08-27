import math
from models import Spirit, Store, StoreInventory, Contact, Hours, Category, Distiller

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
        cursor = connection.cursor()

        cursor.execute("select brand_name, count(*), id, size, total_retail_price from spirits where category = %s group by brand_name order by brand_name", [request.GET['category']])
        
        rows = cursor.fetchall()

    elif 'search' in request.GET:
        cursor = connection.cursor()

        arg = '%' + request.GET['search'] + '%'
        cursor.execute("select brand_name, count(*), id, size, total_retail_price from spirits where brand_name like %s group by brand_name order by brand_name", [arg])
        
        rows = cursor.fetchall()
    else:
        cursor = connection.cursor()

        cursor.execute("select brand_name, count(*), id, size, total_retail_price from spirits group by brand_name order by brand_name")
        
        rows = cursor.fetchall()

    # If spirits has data I still use the compressed json
    if len(spirits):
        for s in spirits:
            sd = s.dict()
            data.append({'n': sd['brand_name'], 
                         'id': sd['id'],
                         's': sd['size'],
                         'p': sd['price']})

    # If rows has data I need the more compressed json dict
    if len(rows):
        for row in rows:
            info = {'n': row[0]}
            if row[1] == 1:
                info['id'] = row[2]
                info['s'] = str(row[3])
                info['p'] = str(row[4])
            else:
                info['c'] = str(row[1])

            data.append(info)

    mimetype = 'application/json'
    return HttpResponse(simplejson.dumps(data),mimetype)

def spirit_inventory(request, spirit_id):
    spirit = get_object_or_404(Spirit, pk=spirit_id)

    ret = []
    for si in spirit.inventory.all():
        store = si.store.dict()

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
    ret = []
    cursor = connection.cursor()

    if 'category' in request.GET:
        cursor = connection.cursor()

        cursor.execute("select s.brand_name, count(*), s.id, s.size, s.total_retail_price from store_inventory si, spirits s where si.store_id = %s and si.spirit_id = s.id and s.category = %s group by brand_name order by brand_name", [store_id, request.GET['category']])
    else:
        cursor.execute("select s.brand_name, count(*), s.id, s.size, s.total_retail_price from store_inventory si, spirits s where si.store_id = %s and si.spirit_id = s.id group by brand_name order by brand_name", [store_id])
        
    rows = cursor.fetchall()
    for row in rows:
        info = {'n': row[0]}
        if row[1] == 1:
            info['id'] = row[2]
            info['s'] = str(row[3])
            info['p'] = str(row[4])
        else:
            info['c'] = str(row[1])

        ret.append(info)

    mimetype = 'application/json'
    return HttpResponse(simplejson.dumps(ret),mimetype)

def store_inventory_grouped(request, store_id):
    ret = []
    cursor = connection.cursor()

    cursor.execute("select s.category from store_inventory si, spirits s where si.store_id = %s and si.spirit_id = s.id group by category order by category", [store_id])
        
    rows = cursor.fetchall()
    for row in rows:
        ret.append(row[0])

    mimetype = 'application/json'
    return HttpResponse(simplejson.dumps(ret),mimetype)

def categories(request):
    mimetype = 'application/json'
    data = simplejson.dumps([c.category for c in Category.objects.all()])
    return HttpResponse(data,mimetype)

def distillers(request):
    mimetype = 'application/json'

    distillers = get_list_or_404(Distiller, 
                                 url__isnull=False)

    data = simplejson.dumps([{'name':d.name, 'id':d.id, 'in_store':d.search_term is not None} for d in distillers])
    return HttpResponse(data,mimetype)

def distiller(request, distiller_id):
    distiller = get_object_or_404(Distiller, pk=distiller_id)

    mimetype = 'application/json'
    return HttpResponse(distiller.json(),mimetype)

    
