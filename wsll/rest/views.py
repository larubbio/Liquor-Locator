from models import Spirit, Store, StoreInventory, Contact, Hours, Category

from django.template import Context, loader
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404

from django.utils import simplejson
from django.core import serializers
json = serializers.get_serializer("json")()

# def load_category(request, id):
#     cat = Category.objects.get(pk=id)
#     children = json.serialize(cat.children.all(), ensure_ascii=False)
#     items = json.serialize(cat.items.all(), ensure_ascii=False)

#     item_images = {}
#     for i in cat.items.all():
#         item_images[i.id] = i.main_image().image_src_url

#     ret = '{"parent":%s,"children":%s,"items":%s,"item_images":%s}' % (id, children, items, simplejson.dumps(item_images))

#     print ret

#     return ret
# #    return simplejson.dumps({'message':'Success','id':id})
# #    return simplejson.dumps({'children':children,'items':items})

# dajaxice_functions.register(load_category)

def spirits(request):
    pass

def spirit_inventory(request, spirit_id):
    spirit = Spirit.objects.get(pk=spirit_id)

    ret = []
    for si in spirit.inventory.all():

        # TODO move into model class as to_json 
        store = {}
        store['city'] = si.store.city
        store['address'] = si.store.address
        store['address2'] = si.store.address2
        store['zip'] = si.store.zip
        store['retail_sales'] = si.store.retail_sales

        hours = []
        for h in si.store.hours.all():
            hours.append(h.__unicode__())

        contacts = []
        for c in si.store.contacts.all():
            contacts.append(c.__unicode__())
        
            
        store['hours'] = hours
        store['contacts'] = contacts

        ret.append(store)

    data = simplejson.dumps(ret)

    mimetype = 'application/json'
    return HttpResponse(data,mimetype)

def spirit(request, spirit_id):
    spirit = Spirit.objects.get(pk=spirit_id)

    # This requires an array
    data = json.serialize([spirit], ensure_ascii=False)

    # but I only want a single element
    data = simplejson.dumps(simplejson.loads(data)[0])

    mimetype = 'application/json'
    return HttpResponse(data,mimetype)

def stores(request):
    stores = Store.objects.all()
    data = json.serialize(stores, ensure_ascii=False)

    mimetype = 'application/json'
    return HttpResponse(data,mimetype)

def categories(request):
#     cat = Category.objects.get(pk=id)
#     children = json.serialize(cat.children.all(), ensure_ascii=False)
#     items = json.serialize(cat.items.all(), ensure_ascii=False)

#     item_images = {}
#     for i in cat.items.all():
#         item_images[i.id] = i.main_image().image_src_url

#     ret = '{"parent":%s,"children":%s,"items":%s,"item_images":%s}' % (id, children, items, simplejson.dumps(item_images))

#     print ret

#     return ret
# #    return simplejson.dumps({'message':'Success','id':id})
# #    return simplejson.dumps({'children':children,'items':items})

    mimetype = 'application/json'
    data = simplejson.dumps([c.category for c in Category.objects.all()])
    return HttpResponse(data,mimetype)
