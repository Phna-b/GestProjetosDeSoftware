# FLASK BACKEND (app.py) - calendário com login e eventos fixos
from flask import Flask, request, jsonify, session
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3

app = Flask(__name__)
app.secret_key = 'super-secret-key'
CORS(app, supports_credentials=True)

DB_NAME = 'calendar.db'

class DBHelper:
    def __init__(self):
        self.conn = sqlite3.connect(DB_NAME, check_same_thread=False)
        self.cursor = self.conn.cursor()
        self.create_tables()

    def create_tables(self):
        self.cursor.execute('''CREATE TABLE IF NOT EXISTS users (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                username TEXT UNIQUE NOT NULL,
                                password TEXT NOT NULL)''')
        self.cursor.execute('''CREATE TABLE IF NOT EXISTS fixed_events (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                title TEXT, date TEXT, time TEXT, description TEXT)''')
        self.conn.commit()

    def add_user(self, username, password):
        try:
            hashed = generate_password_hash(password)
            self.cursor.execute('INSERT INTO users (username, password) VALUES (?, ?)', (username, hashed))
            self.conn.commit()
            return True
        except sqlite3.IntegrityError:
            return False

    def verify_user(self, username, password):
        self.cursor.execute('SELECT password FROM users WHERE username = ?', (username,))
        row = self.cursor.fetchone()
        if row and check_password_hash(row[0], password):
            return True
        return False

    def add_fixed_event(self, title, date, time, description):
        self.cursor.execute('INSERT INTO fixed_events (title, date, time, description) VALUES (?, ?, ?, ?)',
                            (title, date, time, description))
        self.conn.commit()

    def get_events_by_date(self, date):
        self.cursor.execute('SELECT title, date, time, description FROM fixed_events WHERE date = ?', (date,))
        return self.cursor.fetchall()

    def insert_sample_events(self):
        self.cursor.execute('SELECT COUNT(*) FROM fixed_events')
        count = self.cursor.fetchone()[0]
        if count == 0:
            self.add_fixed_event("Reunião mensal", "2025-07-25", "10:00 - 12:00", "Reunião de alinhamento com equipe")
            self.add_fixed_event("Feriado Nacional", "2025-07-30", "11:30 - 15:00", "Comemoração da Liberdade Nacional")
            self.add_fixed_event("Revisão de Projeto", "2025-07-25", "14:00 - 15:00", "Revisar escopo do projeto XPTO")

# Instanciar DB
db = DBHelper()

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    if db.add_user(data['username'], data['password']):
        return jsonify({'message': 'Usuário registrado com sucesso.'}), 201
    else:
        return jsonify({'error': 'Nome de usuário já existe.'}), 409

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    if db.verify_user(data['username'], data['password']):
        session['user'] = data['username']
        return jsonify({'message': 'Login bem-sucedido.'}), 200
    else:
        return jsonify({'error': 'Usuário ou senha incorretos.'}), 401

@app.route('/logout', methods=['POST'])
def logout():
    session.pop('user', None)
    return jsonify({'message': 'Logout realizado.'})

@app.route('/me', methods=['GET'])
def get_current_user():
    user = session.get('user')
    if user:
        return jsonify({'username': user})
    return jsonify({'error': 'Não autenticado.'}), 403

@app.route('/calendar/<date>', methods=['GET'])
def get_events(date):
    rows = db.get_events_by_date(date)
    return jsonify([{'title': r[0], 'date': r[1], 'time': r[2], 'description': r[3]} for r in rows])

db.insert_sample_events()
app.run(debug=True)
