# Create your views here.
from django.http import HttpResponse

def info(request):
    ret = """
<p>Thank you for installing this application!</p>

<p>It was written in response to the two Liquor Privatization measures that are on Washington State's fall ballot, I-1100 and I-1105, that if passed, would privatize liquor sales in our state. We oppose both and hope to use this application to demonstrate why.</p>

<p>Reasons to <b>VOTE NO on I-1100 and I-1105:</b>

<ul>
<li><b>Less information</b> will be available to you, the consumer. As this application demonstrates, there is a large amount of information currently available about liquor store inventory through the state via <a href="http://liq.wa.gov">liq.wa.gov</a>. This very convenient and easy accessibility to information will go away if either initiative passes.</li>

<li><b>Reduced Variety of Liquors</b> to choose from. We believe handing over liquor retailing to private business would result in fewer options. Private stores need to maximize profits with limited shelve space. As a store owner, wouldn't you choose to stock primarily top sellers? This leaves less room for small local distillers or new brands for you, as a consumer, to find.</li>

<li><b>Local Distillers</b> Recent changes to state laws have made it easier for local micro-distillers to start up. Currently, at least five distillers have new products in stores, and dozens more are on the way. These are small businesses who create jobs in our communities and purchase source materials from Washington farmers, and are making creative and unique spirits. While this industry won't completely disappear if the initiatives pass, we believe it will become significantly harder to get new or small-batch product into a private enterprises, such as Costco. </li>
</ul>
</p>

<p>Please vote <b>NO</b> this November to keep <b>information</b> and <b>choice</b> part of your responsible consumption of alcohol.</p>

<p>If you have comments or suggestions please email <a href="mailto:rob.larubbio@pugdogdev.com">rob.larubbio@pugdogdev.com</a></p>
"""
    return HttpResponse(ret)
