# Create your views here.
from django.http import HttpResponse

def info(request):
    return HttpResponse("Thank You..")
