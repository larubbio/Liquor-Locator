import cgi
import logging
import os
import uuid
import datetime

from google.appengine.ext import db
from google.appengine.ext import webapp

from google.appengine.ext.webapp import template

from google.appengine.ext.webapp.util import run_wsgi_app

def getUserId(request, response):
    id = None

    if 'user' in request.cookies:
        id = request.cookies['user']
    else:
        id = uuid.uuid4()
        expiration = datetime.datetime.now() + datetime.timedelta(days=30)
        response.headers.add_header('Set-Cookie','user=%s; expires=%s; path=/;' % (id, expiration.strftime("%a, %d-%b-%Y %H:%M:%S PST")))

    return id


class Rating(db.Model):
    author = db.StringProperty(required=True)
    name = db.StringProperty(required=True)
    rating = db.IntegerProperty(required=True)
    comment = db.StringProperty(multiline=True)

class MainPage(webapp.RequestHandler):
    def get(self):
        user = getUserId(self.request, self.response)

        path = os.path.join(os.path.dirname(__file__), 'index.html')
        self.response.out.write(template.render(path, {}))

class NamePage(webapp.RequestHandler):

    name_map = {'1':'east roanoke',
                '2':'fig & finch',
                '3':'mercury martin',
                '4':'east olive',
                }

    def get(self, name_id):
        user = getUserId(self.request, self.response)
        
        if int(name_id) == 4:
            next = '/thankyou'
        else:
            next = '/name/%s' % (int(name_id) + 1)

        template_values = {
            'next' : next,
            'name' : self.name_map[name_id],
            'id' : name_id
            }

        path = os.path.join(os.path.dirname(__file__), 'name.html')
        self.response.out.write(template.render(path, template_values))

class ThankYouPage(webapp.RequestHandler):
    def get(self):
        user = getUserId(self.request, self.response)

        template_values = {
            }

        path = os.path.join(os.path.dirname(__file__), 'thankyou.html')
        self.response.out.write(template.render(path, template_values))

class RecordVote(webapp.RequestHandler):
    def post(self):
        user = getUserId(self.request, self.response)

        if len(self.request.get('rating')) == 0:
            self.redirect('/name/%s' % (self.request.get('id')))
        else:
            key = user

            rating = Rating.get_or_insert(key_name=key,
                                          rating=int(self.request.get('rating')),
                                          comment=self.request.get('comment'),
                                          author=user,
                                          name=self.request.get('name'))

            # I need to duplicate these setters down here since the above
            # only uses them if the record didn't exist.  
            rating.rating=int(self.request.get('rating'))
            rating.comment=self.request.get('comment')
            rating.author=user
            rating.name=self.request.get('name')
            
            rating.put()

            self.redirect(self.request.get('next'))

class ResultsPage(webapp.RequestHandler):

    name_map = {'1':'east roanoke',
                '2':'fig & finch',
                '3':'mercury martin',
                '4':'east olive',
                }

    def get(self):
        
        results_map = {}

        for name in self.name_map.values():
            results_map[name] = {}
            results_map[name]['name'] = name

            q = Rating.all()
            q.filter("name =", name)

            results_map[name]['records'] = q.fetch(1000)

            total = 0
            for result in results_map[name]['records']:
                total = total + result.rating

            count = len(results_map[name]['records'])
            results_map[name]['count'] = count

            if count == 0:
                results_map[name]['avg'] = 'N/A'
            else:
                results_map[name]['avg'] = total / count

        logging.info(results_map)
        template_values = {
            'results' : results_map.values(),
            }

        path = os.path.join(os.path.dirname(__file__), 'results.html')
        self.response.out.write(template.render(path, template_values))


application = webapp.WSGIApplication(
                                     [('/', MainPage),
                                      ('/thankyou', ThankYouPage),
                                      ('/vote', RecordVote),
                                      ('/results', ResultsPage),
                                      ('/name/(.*)', NamePage)],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()
