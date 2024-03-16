import os
import time
from flask import Flask, render_template, request, redirect, url_for, jsonify , make_response
from sqlalchemy import create_engine
from flask_sqlalchemy import SQLAlchemy


DB_USER=      os.environ.get('DB_USER')          or 'idubi'   
DB_PASSWORD=  os.environ.get('DB_PASSWORD')      or 'idubi' 
DB_NAME=      os.environ.get('DB_NAME')          or 'idubi' 
DB_TYPE=      os.environ.get('DB_TYPE')          or  'postgresql' 
DB_HOST=      os.environ.get('DB_HOST')          or 'localhost' 
DB_PORT=      os.environ.get('DB_PORT')          or '5432' 
app = Flask(__name__)
connection_string= f"{DB_TYPE}://{DB_USER}:{DB_NAME}@{DB_HOST}:5432/{DB_PASSWORD}"

print (f"  (1) ----->   CONNECTING : {connection_string}")

app.config['SQLALCHEMY_DATABASE_URI'] = connection_string

db = SQLAlchemy(app)



class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    
def create_user(name, email):
    # Access the database within the application context
    print ("  (2) ----->   execute create user")
    with app.app_context():
        new_user = User(name=name, email=email)
        db.session.add(new_user)
        db.session.commit()
@app.route('/')
def index():
    return render_template('index.html')



# @app.route('/ALL/')
# def all_users():
#     registered_users = User.query.all()
#     # Pass `registered_users` to your template
#     return render_template_string(HTML_TEMPLATE, registered_users=registered_users)


@app.route('/save', methods=['POST'])
def save_user():
    name = request.form['name']
    email = request.form['email']
    new_user = User(name=name, email=email)
    db.session.add(new_user)
    db.session.commit()
    return redirect(url_for('index'))



@app.route('/hello/<name>')
def hello(name):
    return f'Hello, {name}!'

@app.route('/ping', methods=['POST'])
def ping():
    # return 'pong'
    response_data = {'message':'pong'}
    response = make_response(jsonify(response_data), 200)
    response.headers['X-Custom-Header'] = 'Value'
    return response


print (f'   (3) ---------> __name__ = {__name__}')
if __name__ in ['__main__','app']:
    print (f'   (4) ---------> __name__ = {__name__}')
    with app.app_context():
        db.create_all()
    app.run(debug=True)
