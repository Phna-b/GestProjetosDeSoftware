Sistema de Gestão para a Semana da Computação do DECSI
Este é um projeto universitário desenvolvido para a disciplina de Gerência de Projetos de Software (CSI405) da Universidade Federal de Ouro Preto (UFOP). O sistema foi construído para dar suporte à Semana da Computação do Departamento de Computação e Sistemas (DECSI), com o objetivo de centralizar informações e melhorar a experiência dos participantes.

A aplicação consiste num backend desenvolvido em Python com Flask e um frontend em Flutter, que se comunicam para fornecer as funcionalidades.

Funcionalidades Principais
Autenticação de Utilizadores: Sistema de registo e login para os participantes.

Calendário de Eventos: Visualização da programação completa do evento, com a capacidade de filtrar eventos por dia.

Detalhes do Evento: Visualização de informações detalhadas sobre cada palestra ou atividade.

Agenda Personalizada: Funcionalidade que permite aos utilizadores inscreverem-se nos eventos de seu interesse (em desenvolvimento).

Envio de Perguntas: Sistema para que os participantes possam enviar perguntas durante as palestras (em desenvolvimento).

Tecnologias Utilizadas
O projeto foi dividido em duas partes principais: o backend e o frontend.

Backend 🐍
Linguagem: Python

Framework: Flask

Dependências Principais:

Flask: O micro-framework principal para a criação do servidor.

Flask-SQLAlchemy: Para a interação com a base de dados de forma mais simples e robusta.

Flask-Cors: Para gerir as permissões de comunicação entre o frontend e o backend.

Werkzeug: Para o sistema de hashing de passwords e segurança.

Base de Dados: SQLite

Frontend 📱
Framework: Flutter

Linguagem: Dart

Dependências Principais (pubspec.yaml):

http: Para fazer as requisições HTTP e comunicar com o backend Flask.

table_calendar: Para a criação e visualização do calendário interativo.

intl: Para a formatação de datas.

Como Executar o Projeto
É necessário executar o backend e o frontend em terminais separados.

1. Executar o Backend (Servidor Flask)
O backend é responsável por servir os dados para a aplicação.

Bash

# 1. Navegue para a pasta do backend
cd "Flutter project/Flask"

# 2. Instale as dependências (apenas na primeira vez)
pip install Flask Flask-SQLAlchemy Flask-Cors Werkzeug

# 3. Inicie o servidor
py run.py
O terminal irá indicar que o servidor está a ser executado em http://127.0.0.1:5000. Deixe este terminal aberto.

2. Executar o Frontend (Aplicação Flutter)
Com o backend a ser executado, inicie a aplicação visual.

Bash

# 1. Navegue para a pasta do frontend
cd "Flutter project/flutter_application_1"

# 2. Descarregue as dependências do Flutter (apenas na primeira vez)
flutter pub get

# 3. Execute a aplicação (escolha uma das opções abaixo)

# Para executar no navegador Chrome
flutter run -d chrome

# Para executar num emulador Android (se tiver um configurado)
flutter run
A aplicação irá iniciar e conectar-se automaticamente ao backend.