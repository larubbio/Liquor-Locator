#from models import Category

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
