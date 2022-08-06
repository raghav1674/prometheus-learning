from flask import Flask,request
from prometheus_client import start_http_server,Counter

INDEX_REQUEST_COUNT = Counter('custom_python_index_request_count','number of times the index page is visited',['method','endpoint'])

app = Flask(__name__)

@app.route('/',methods=['GET'])
def index():
    INDEX_REQUEST_COUNT.labels(request.method,request.path).inc()
    return 'Hello World'

@app.errorhandler(404)
def page404(e):
    INDEX_REQUEST_COUNT.labels(request.method,request.path).inc()
    return 'NOT FOUND'

if __name__ == '__main__':
    start_http_server(8000)
    app.run(host='0.0.0.0',port=9090)

'''
            METRICS TYPE
            ------------
COUNT -> can be incremented
GUAGE -> can be inc,dec and set
Summary -> to observe for some time period
INFO -> key/value pair
'''