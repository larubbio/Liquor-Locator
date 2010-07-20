from django.utils import simplejson as json

def to_json(model):
    ret = ''

    if isinstance(model, list):
        elements = []

        for m in model:
            elements.append(m.to_dict())

        ret = json.dumps(elements)

    elif isinstance(model, dict):

        ret = json.dumps(model)

    else:

        ret = json.dumps(model.to_dict())

    return ret

def loads(body):
    return json.loads(body)
