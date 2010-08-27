# Create your views here.
from django.http import HttpResponse

def info(request):
    ret = """
<p>Thank You for installing my application.</p>
<p>I wrote it in response to the two Liquor Privatition measures that are on this fall's ballot.  I'm opposed to both and I hope to use this application to demonstrate why.  While <a href="http://keepourchildrensafe.org/">Keep Our Children Safe</a> lists several good reasons for opposing this initiatives, my reasons differ.  This application is not affiliated with them.</p>
<p>I opposee these two initiatives for the following reasons:</p>
<ul>
<li>Information<br>
As this application hopefully demonstrates, there is a large amount of information available about liquor store inventory.  I find this extremly convienient and it is sure to go away if either initiative passes</li>
<li>Variety<br>
It's my belief that handing over liquor retailing to private business would result in fewer options.  Private stores have to maximize profits and have limited shelve space to share across all items.  If you were in their situation would you carry over 4000 unique brands that state stores do, or just a lot of the top sellers?  Personally I'm interested in trying new brands, so I support the state stores.</li>
<li>Local Distillers<br>
Changes to state laws have made it easier for local micro-distillers to start up.  Currently at least 5 have products in stores with dozeens more on the way.  These are small business who create jobs in our communities and purchase source materials from Washington farmers.  In addition they make some create spirits.  While this industry won't dissapear if the initiatives pass, it will make things significantly harder on them since the bar to get product into a state store is a lot easier to reach then it is to get into Costco.</li>
</ul>

If that isn't enough to convince you, let me tell you about features I'll add in version 2 (if there is one):

<ul>
<li>Filtering:
<ul>
<li>See only items within a certain distance from you</li>
<li>See only items at stores currently open</li>
<li>See only items that are discounted</li>
</ul>
</li>
</ul>

<p>Thank you, and if you have comments or suggestions please email me at <a href="mailto:wsll@pugdogdev.com">wsll@pugdogdev.com</a></p>"""
    return HttpResponse(ret)
