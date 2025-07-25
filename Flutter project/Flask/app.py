# app.py (versão com CORS corrigido para desenvolvimento)

from flask import Flask, request, jsonify, session
from flask_cors import CORS
from flask_session import Session
from datetime import datetime

app = Flask(__name__)

app.config["SECRET_KEY"] = "sua-chave-secreta-deve-ser-dificil-de-adivinhar"
app.config["SESSION_TYPE"] = "filesystem"
app.config["SESSION_COOKIE_SAMESITE"] = "None" 
app.config["SESSION_COOKIE_SECURE"] = True
Session(app)

# --- ALTERAÇÃO PRINCIPAL AQUI ---
CORS(app, supports_credentials=True, resources={
    r"/*": {
        # Permite pedidos de qualquer origem. Ideal para desenvolvimento local.
        "origins": "*", 
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})


@app.before_request
def require_login():
    if request.method == 'OPTIONS':
        return
    exempt_routes = ['login']
    if request.endpoint not in exempt_routes and 'user_id' not in session:
        return jsonify({"error": "Autenticação necessária, por favor faça login."}), 401


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    print(f"Dados recebidos para login: {data}") # Mantendo a depuração
    
    username = data.get('username')
    password = data.get('password')

    if username == 'juju' and password == '123456':
        session['user_id'] = 1
        session['username'] = username
        print(f"✅ Usuário '{username}' logado com sucesso. ID da sessão: {session.sid}")
        return jsonify({"message": "Login bem-sucedido.", "user_id": 1}), 200
    else:
        print(f"❌ Falha no login para o usuário '{username}'. Credenciais não correspondem.")
        return jsonify({"error": "Credenciais inválidas"}), 401

@app.route('/logout', methods=['POST'])
def logout():
    print(f"✅ Usuário '{session.get('username')}' fazendo logout.")
    session.clear()
    return jsonify({"message": "Logout bem-sucedido."}), 200

@app.route('/events', methods=['GET'])
def get_events():
    user_id = session.get('user_id')
    print(f"✅ Buscando eventos para o usuário ID: {user_id}")
    
    events = [
        {"id": 1, "title": "Palestra de Boas-Vindas", "time": "09:00", "date": "2025-07-28T09:00:00", "description": "Abertura da Semana da Computação."},
        {"id": 2, "title": "Workshop de Docker", "time": "14:00", "date": "2025-07-28T14:00:00", "description": "Introdução a contêineres com Docker."},
        {"id": 3, "title": "Palestra de IA", "time": "10:00", "date": "2025-07-29T10:00:00", "description": "O futuro da Inteligência Artificial."}
    ]
    return jsonify(events)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)