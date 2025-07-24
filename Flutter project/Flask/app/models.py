# app/models.py
from . import db
from werkzeug.security import generate_password_hash, check_password_hash
import datetime

# Tabela de associação para as inscrições (agenda personalizada)
registrations = db.Table('registrations',
    db.Column('user_id', db.Integer, db.ForeignKey('user.id'), primary_key=True),
    db.Column('event_id', db.Integer, db.ForeignKey('event.id'), primary_key=True)
)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    # Relacionamento para aceder aos eventos em que o utilizador se inscreveu
    subscribed_events = db.relationship('Event', secondary=registrations, lazy='subquery',
        backref=db.backref('subscribers', lazy=True))

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(120), nullable=False)
    date = db.Column(db.String(10), nullable=False)
    time = db.Column(db.String(50), nullable=True)
    description = db.Column(db.Text, nullable=True)
    # Relacionamento para aceder às perguntas de um evento
    questions = db.relationship('Question', backref='event', lazy=True)

class Question(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, index=True, default=datetime.datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    event_id = db.Column(db.Integer, db.ForeignKey('event.id'), nullable=False)
    # Relacionamento para aceder ao autor de uma pergunta
    author = db.relationship('User', backref='questions')