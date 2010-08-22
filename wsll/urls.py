from django.conf.urls.defaults import *
from django.conf import settings

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    (r'^spirits$', 'wsll.rest.views.spirits'),
    (r'^spirit/(?P<spirit_id>\d+)/stores$', 'wsll.rest.views.spirit_inventory'),
    (r'^spirit/(?P<spirit_id>\d+)$', 'wsll.rest.views.spirit'),
    (r'^stores$', 'wsll.rest.views.stores'),
    (r'^store/(?P<store_id>\d+)$', 'wsll.rest.views.store'),
    (r'^store/(?P<store_id>\d+)/spirits$', 'wsll.rest.views.store_inventory'),
    (r'^categories$', 'wsll.rest.views.categories'),
    ('info', 'wsll.html.views.info'),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    (r'^admin/', include(admin.site.urls)),
)
