import docker
from flask import Flask
from flask import abort
from flask import request
from flask import Response
from flask import url_for
from flask import render_template

app = Flask(__name__)

@app.route('/logs')
def generate_logs():
    d = docker.Client('http://localhost:4343', '1.8')
    #print(d)
    body = d.logs("f7758e4a811de153a6910846ea6b7e59df243568c8a49fdfa3010524d543a90c", stream=True)
    #print(body)
    return Response(body, mimetype='text/plain')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/build/<build_id>/logs')
def build_logs(build_id):
    abort(404)


@app.route('/github_webhook', methods=['POST'])
def github_webhook(hello):
    pass

@app.errorhandler(404)
def not_found(error):
    return render_template('error.html'), 404


if __name__ == '__main__':
    app.debug = True
    app.run()

