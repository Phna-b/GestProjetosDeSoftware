# app/__init__.py

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS # 👈 1. Importe o CORS

# Inicializa o banco de dados (ainda sem app)
db = SQLAlchemy()

def create_app():
    """Cria e configura uma instância da aplicação Flask."""
    app = Flask(__name__)

    # --- Configurações Essenciais ---
    # Chave secreta para sessões (necessária para session['user_id'])
    app.config['SECRET_KEY'] = 'uma-chave-secreta-muito-segura-e-dificil-de-adivinhar' 
    
    # Configuração do banco de dados (usando SQLite como exemplo)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///meubanco.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # 👇 2. Aplique o CORS à sua aplicação
    # Isso permitirá requisições de todas as origens para todas as rotas
    CORS(app, supports_credentials=True)

    # Associa a instância do banco de dados com a aplicação
    db.init_app(app)

    # --- Importa e registra rotas e modelos ---
    with app.app_context():
        # Importa as rotas para que elas sejam registradas
        from . import routes 
        # Importa os modelos para que o SQLAlchemy saiba sobre eles
        from . import models
        
        # Cria as tabelas do banco de dados, se não existirem
        db.create_all()

    return app