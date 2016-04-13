import json
import os
import time
from flask import Flask, Response, request

app = Flask(__name__, static_url_path='', static_folder='.')
app.add_url_rule('/', 'root', lambda: app.send_static_file('index.html'))

@app.route('/api/repos/library', methods=['GET', 'POST'])
def responses_handler():

    with open('library.json', 'r') as file:
        responses = json.loads(file.read())

    return Response(json.dumps(responses), mimetype='application/json', headers={'Cache-Control': 'no-cache', 'Access-Control-Allow-Origin': '*'})

if __name__ == '__main__':
    app.run(port=int(os.environ.get("PORT",3000)))
