# app/__init__.py

from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

app = Flask(__name__)
app.secret_key = 'super-secret-key-muito-segura'
# Define o caminho da base de dados
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///../calendar.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

CORS(app, supports_credentials=True, resources={r"/*": {"origins": "*"}})

db.init_app(app)

from app import routes