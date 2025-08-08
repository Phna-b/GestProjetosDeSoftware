# app.py - Backend com CORS flexível (aceita qualquer porta localhost no dev), autenticação JWT,
# subscriptions e endpoints para criar/inscrever/excluir eventos.
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import sqlite3
import jwt
import datetime
import os

DB_NAME = 'calendar.db'
SECRET_KEY = os.environ.get('SECRET_KEY', 'super-secret-key')  # troque em produção

class DBHelper:
    def __init__(self):
        self.conn = sqlite3.connect(DB_NAME, check_same_thread=False)
        self.cursor = self.conn.cursor()
        self.create_tables()
        try:
            self.cursor.execute("PRAGMA table_info(fixed_events)")
            cols = [c[1] for c in self.cursor.fetchall()]
            if 'user_id' not in cols:
                self.cursor.execute("ALTER TABLE fixed_events ADD COLUMN user_id INTEGER")
                self.conn.commit()
        except Exception:
            pass

    def create_tables(self):
        self.cursor.execute('''CREATE TABLE IF NOT EXISTS users (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                username TEXT UNIQUE NOT NULL,
                                password TEXT NOT NULL)''')

        self.cursor.execute('''CREATE TABLE IF NOT EXISTS fixed_events (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                title TEXT,
                                date TEXT,
                                time TEXT,
                                description TEXT,
                                user_id INTEGER
                              )''')

        self.cursor.execute('''CREATE TABLE IF NOT EXISTS subscriptions (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                user_id INTEGER NOT NULL,
                                event_id INTEGER NOT NULL,
                                UNIQUE(user_id, event_id)
                              )''')
        self.conn.commit()

    # Users
    def add_user(self, username, password):
        try:
            hashed = generate_password_hash(password)
            self.cursor.execute('INSERT INTO users (username, password) VALUES (?, ?)', (username, hashed))
            self.conn.commit()
            return True
        except sqlite3.IntegrityError:
            return False

    def verify_user(self, username, password):
        self.cursor.execute('SELECT id, password FROM users WHERE username = ?', (username,))
        row = self.cursor.fetchone()
        if row and check_password_hash(row[1], password):
            return row[0]
        return None

    def get_user_id(self, username):
        self.cursor.execute('SELECT id FROM users WHERE username = ?', (username,))
        row = self.cursor.fetchone()
        return row[0] if row else None

    # Events
    def create_event(self, title, date, time, description, user_id=None):
        self.cursor.execute(
            'INSERT INTO fixed_events (title, date, time, description, user_id) VALUES (?, ?, ?, ?, ?)',
            (title, date, time, description, user_id)
        )
        self.conn.commit()
        return self.cursor.lastrowid

    def event_exists(self, event_id):
        self.cursor.execute('SELECT id FROM fixed_events WHERE id = ?', (event_id,))
        return self.cursor.fetchone() is not None

    def get_events_by_date(self, date):
        self.cursor.execute('SELECT id, title, date, time, description, user_id FROM fixed_events WHERE date = ?', (date,))
        return self.cursor.fetchall()

    def get_user_events_by_date(self, user_id, date):
        self.cursor.execute('SELECT id, title, date, time, description, user_id FROM fixed_events WHERE date = ? AND user_id = ?', (date, user_id))
        return self.cursor.fetchall()

    def get_event_by_id(self, event_id):
        self.cursor.execute('SELECT id, title, date, time, description, user_id FROM fixed_events WHERE id = ?', (event_id,))
        return self.cursor.fetchone()

    def delete_event(self, event_id):
        self.cursor.execute('DELETE FROM fixed_events WHERE id = ?', (event_id,))
        self.conn.commit()
        return self.cursor.rowcount > 0

    def remove_subscriptions_for_event(self, event_id):
        self.cursor.execute('DELETE FROM subscriptions WHERE event_id = ?', (event_id,))
        self.conn.commit()

    # Subscriptions
    def add_subscription(self, user_id, event_id):
        try:
            self.cursor.execute('INSERT INTO subscriptions (user_id, event_id) VALUES (?, ?)', (user_id, event_id))
            self.conn.commit()
            return True
        except sqlite3.IntegrityError:
            return False

    def remove_subscription(self, user_id, event_id):
        self.cursor.execute('DELETE FROM subscriptions WHERE user_id = ? AND event_id = ?', (user_id, event_id))
        self.conn.commit()
        return self.cursor.rowcount > 0

    def get_subscribed_event_ids(self, user_id):
        self.cursor.execute('SELECT event_id FROM subscriptions WHERE user_id = ?', (user_id,))
        return [r[0] for r in self.cursor.fetchall()]

    def get_subscribed_events(self, user_id):
        self.cursor.execute('''
            SELECT fe.id, fe.title, fe.date, fe.time, fe.description, fe.user_id
            FROM fixed_events fe
            JOIN subscriptions s ON s.event_id = fe.id
            WHERE s.user_id = ?
        ''', (user_id,))
        return self.cursor.fetchall()

    # seed
    def insert_sample_events(self):
        self.cursor.execute('SELECT COUNT(*) FROM fixed_events')
        count = self.cursor.fetchone()[0]
        if count == 0:
            self.create_event("Reunião mensal", "2025-07-25", "10:00 - 12:00", "Reunião de alinhamento com equipe", None)
            self.create_event("Feriado Nacional", "2025-07-30", "11:30 - 15:00", "Comemoração da Liberdade Nacional", None)
            self.create_event("Revisão de Projeto", "2025-07-25", "14:00 - 15:00", "Revisar escopo do projeto XPTO", None)

# Flask app
app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

# CORS aceitando qualquer porta em localhost para facilitar no desenvolvimento
CORS(
    app,
    supports_credentials=True,
    resources={r"/*": {"origins": [r"http://localhost:\d+", r"http://127.0.0.1:\d+"]}},
    allow_headers=["Content-Type", "Authorization"],
    expose_headers=["Authorization"],
    methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"]
)

@app.route('/events/<int:event_id>', methods=['GET'])
def get_event_details(event_id):
    ev = db.get_event_by_id(event_id)
    if not ev:
        return jsonify({'error': 'Evento não encontrado.'}), 404
    return jsonify({
        'id': ev[0],
        'title': ev[1],
        'date': ev[2],
        'time': ev[3],
        'description': ev[4],
        'user_id': ev[5]
    })


@app.after_request
def add_cors_headers(response):
    origin = request.headers.get('Origin')
    if origin and (origin.startswith('http://localhost') or origin.startswith('http://127.0.0.1')):
        response.headers['Access-Control-Allow-Origin'] = origin
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Methods'] = 'GET,POST,PUT,DELETE,OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    return response

db = DBHelper()

# JWT helpers
def create_token(username):
    exp = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(hours=24)
    payload = {'username': username, 'exp': exp}
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    if isinstance(token, bytes):
        token = token.decode('utf-8')
    return token

def decode_token(auth_header):
    if not auth_header:
        return None
    parts = auth_header.split()
    if len(parts) != 2 or parts[0].lower() != 'bearer':
        return None
    token = parts[1]
    try:
        data = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return data
    except jwt.ExpiredSignatureError:
        return None
    except Exception:
        return None

# --- Endpoints ---
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    username = (data.get('username') or '').strip()
    password = data.get('password') or ''
    if not username or not password:
        return jsonify({'error': 'Usuário e senha são obrigatórios.'}), 400
    if len(username) < 3:
        return jsonify({'error': 'Nome de usuário muito curto (mínimo 3 caracteres).'}), 400
    if len(password) < 4:
        return jsonify({'error': 'Senha muito curta (mínimo 4 caracteres).'}), 400
    created = db.add_user(username, password)
    if created:
        return jsonify({'message': 'Usuário registrado com sucesso.'}), 201
    else:
        return jsonify({'error': 'Nome de usuário já existe.'}), 409

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    username = (data.get('username') or '').strip()
    password = data.get('password') or ''
    if not username or not password:
        return jsonify({'error': 'Usuário e senha são obrigatórios.'}), 400
    user_id = db.verify_user(username, password)
    if user_id:
        token = create_token(username)
        return jsonify({'message': 'Login bem-sucedido.', 'username': username, 'token': token}), 200
    else:
        return jsonify({'error': 'Usuário ou senha incorretos.'}), 401

@app.route('/calendar/<date>', methods=['GET'])
def get_events(date):
    rows = db.get_events_by_date(date)
    return jsonify([{'id': r[0], 'title': r[1], 'date': r[2], 'time': r[3], 'description': r[4], 'user_id': r[5]} for r in rows])

@app.route('/events', methods=['OPTIONS', 'GET', 'POST'])
def events_root():
    if request.method == 'OPTIONS':
        return ('', 200)
    if request.method == 'GET':
        date = request.args.get('date')
        if date:
            rows = db.get_events_by_date(date)
        else:
            today = datetime.datetime.now(datetime.timezone.utc).date().isoformat()
            rows = db.get_events_by_date(today)
        return jsonify([{'id': r[0], 'title': r[1], 'date': r[2], 'time': r[3], 'description': r[4], 'user_id': r[5]} for r in rows])
    # POST cria evento
    auth = request.headers.get('Authorization', None)
    data_token = decode_token(auth)
    if not data_token:
        return jsonify({'error': 'Token inválido ou expirado.'}), 401
    username = data_token.get('username')
    user_id = db.get_user_id(username)
    if user_id is None:
        return jsonify({'error': 'Usuário não encontrado.'}), 404
    payload = request.get_json() or {}
    title = payload.get('title')
    date = payload.get('date')
    time = payload.get('time') or None
    description = payload.get('description', '')
    if not title or not date:
        return jsonify({'error': 'title e date são obrigatórios.'}), 400
    new_id = db.create_event(title, date, time, description, user_id=user_id)
    return jsonify({'message': 'Evento criado.', 'event_id': new_id}), 201

@app.route('/events/<int:event_id>', methods=['DELETE'])
def delete_event_route(event_id):
    auth = request.headers.get('Authorization', None)
    data_token = decode_token(auth)
    if not data_token:
        return jsonify({'error': 'Token inválido ou expirado.'}), 401
    username = data_token.get('username')
    user_id = db.get_user_id(username)
    if user_id is None:
        return jsonify({'error': 'Usuário não encontrado.'}), 404

    ev = db.get_event_by_id(event_id)
    if not ev:
        return jsonify({'error': 'Evento não encontrado.'}), 404
    owner_id = ev[5]
    if owner_id != user_id:
        return jsonify({'error': 'Você não tem permissão para excluir este evento.'}), 403

    db.remove_subscriptions_for_event(event_id)
    deleted = db.delete_event(event_id)
    if deleted:
        return jsonify({'message': 'Evento deletado.'}), 200
    else:
        return jsonify({'error': 'Falha ao excluir evento.'}), 500

@app.route('/my/events/<date>', methods=['GET'])
def get_my_events(date):
    auth = request.headers.get('Authorization', None)
    data = decode_token(auth)
    if not data:
        return jsonify({'error': 'Token inválido ou expirado.'}), 401
    username = data.get('username')
    user_id = db.get_user_id(username)
    if user_id is None:
        return jsonify({'error': 'Usuário não encontrado.'}), 404
    rows = db.get_user_events_by_date(user_id, date)
    return jsonify([{'id': r[0], 'title': r[1], 'date': r[2], 'time': r[3], 'description': r[4], 'user_id': r[5]} for r in rows])

@app.route('/my_agenda', methods=['OPTIONS', 'GET'])
def my_agenda():
    if request.method == 'OPTIONS':
        return ('', 200)
    auth = request.headers.get('Authorization', None)
    data_token = decode_token(auth)
    if not data_token:
        return jsonify({'error': 'Token inválido ou expirado.'}), 401
    username = data_token.get('username')
    user_id = db.get_user_id(username)
    if user_id is None:
        return jsonify({'error': 'Usuário não encontrado.'}), 404
    rows_sub = db.get_subscribed_events(user_id)
    db.cursor.execute('SELECT id, title, date, time, description, user_id FROM fixed_events WHERE user_id = ?', (user_id,))
    rows_own = db.cursor.fetchall()
    merged = []
    seen = set()
    for r in list(rows_sub) + list(rows_own):
        if r[0] not in seen:
            merged.append(r)
            seen.add(r[0])
    return jsonify([{'id': r[0], 'title': r[1], 'date': r[2], 'time': r[3], 'description': r[4], 'user_id': r[5]} for r in merged])

@app.route('/subscribe', methods=['POST'])
def subscribe():
    auth = request.headers.get('Authorization', None)
    data_token = decode_token(auth)
    if not data_token:
        return jsonify({'error': 'Token inválido ou expirado.'}), 401
    username = data_token.get('username')
    user_id = db.get_user_id(username)
    if user_id is None:
        return jsonify({'error': 'Usuário não encontrado.'}), 404
    payload = request.get_json() or {}
    event_id = payload.get('event_id')
    if not event_id:
        return jsonify({'error': 'event_id é obrigatório.'}), 400
    if not db.event_exists(event_id):
        return jsonify({'error': 'Evento não encontrado.'}), 404
    success = db.add_subscription(user_id, event_id)
    if success:
        return jsonify({'message': 'Inscrição realizada.'}), 201
    else:
        return jsonify({'error': 'Já inscrito ou evento inválido.'}), 409

@app.route('/unsubscribe', methods=['POST'])
def unsubscribe():
    auth = request.headers.get('Authorization', None)
    data_token = decode_token(auth)
    if not data_token:
        return jsonify({'error': 'Token inválido ou expirado.'}), 401
    username = data_token.get('username')
    user_id = db.get_user_id(username)
    if user_id is None:
        return jsonify({'error': 'Usuário não encontrado.'}), 404
    payload = request.get_json() or {}
    event_id = payload.get('event_id')
    if not event_id:
        return jsonify({'error': 'event_id é obrigatório.'}), 400
    removed = db.remove_subscription(user_id, event_id)
    if removed:
        return jsonify({'message': 'Inscrição removida.'}), 200
    else:
        return jsonify({'error': 'Inscrição não encontrada.'}), 404

# seed initial events
db.insert_sample_events()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
