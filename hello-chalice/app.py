from chalice import Chalice

app = Chalice(app_name='hello-chalice')


@app.route('/')
def index():
    return {'hola': 'chalice'}

@app.route('/foo')
def foo():
    return {'bar': 'baz'}

@app.on_s3_event(bucket='mwh-test-chalice-bucket')
def handler(event):
    print("Object uploaded for bucket: %s, key: %s"
          % (event.bucket, event.key))
# The view function above will return {"hello": "world"}
# whenever you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.current_request.json_body
#     # We'll echo the json body back to the user in a 'user' key.
#     return {'user': user_as_json}
#
# See the README documentation for more examples.
#
