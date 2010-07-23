from models import Spirit, Store, StoreInventory, Contact, Hours, Category
from django.contrib import admin

class HoursInline(admin.StackedInline):
    model = Hours
    extra = 3

class StoreAdmin(admin.ModelAdmin):
    inlines = [HoursInline]

class CategoryAdmin(admin.ModelAdmin):
    readonly_fields = ['category']

admin.site.register(Spirit)
admin.site.register(Store, StoreAdmin)
admin.site.register(StoreInventory)
admin.site.register(Category, CategoryAdmin)
