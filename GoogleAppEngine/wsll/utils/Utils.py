import logging
from google.appengine.ext import db
import utils.JSONUtils as JSONUtils

def catalogFromId(request, cid):
    key = db.Key.from_path('Catalog', cid)
    catalog = db.get(key)

    logging.info(key)

    if catalog is None:
        request.error(400)
        request.response.out.write(JSONUtils.to_json({'status':'error', 'msg':'catalog id is invalid'}))

        return None

    return catalog

def verifyRequiredArg(request, arg, arg_name, func):
    value = None

    if arg is None or arg is '':
        request.error(400)
        request.response.out.write(JSONUtils.to_json({'status':'error', 'msg':'%s is required' % arg_name}))
                                    
        return None

    return verifyArg(request, arg, arg_name, func)

def verifyArg(request, arg, arg_name, func):
    if arg is None or arg is '':
        return None

    try:
        value = func(arg)
    except ValueError:
        request.error(400)
        request.response.out.write(JSONUtils.to_json({'status':'error', 'msg':'%s is of wrong type' % arg_name}))
                                    
        return None

    return value

