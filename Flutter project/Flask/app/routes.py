# app/routes.py

from flask import request, jsonify, session
from app import app, db
from app.models import User, Event, Question

@app.route('/', methods=['GET'])
def index():
    return jsonify({'message': 'O servidor Flask está a funcionar!'})

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    if User.query.filter_by(username=data.get('username')).first():
        return jsonify({'error': 'Nome de usuário já existe.'}), 409
    
    new_user = User(username=data.get('username'))
    new_user.set_password(data.get('password'))
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({'message': 'Usuário registrado com sucesso.'}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(username=data.get('username')).first()
    if user and user.check_password(data.get('password')):
        session['user_id'] = user.id
        return jsonify({'message': 'Login bem-sucedido.', 'user_id': user.id}), 200
    
    return jsonify({'error': 'Usuário ou senha incorretos.'}), 401

@app.route('/events', methods=['GET'])
def get_events():
    events = Event.query.all()
    events_list = [{'id': e.id, 'title': e.title, 'date': e.date, 'time': e.time, 'description': e.description} for e in events]
    return jsonify(events_list)

@app.route('/events', methods=['POST'])
def create_event():
    data = request.json
    new_event = Event(
        title=data.get('title'),
        description=data.get('description'),
        date=data.get('date'),
        time=data.get('time', '') 
    )
    db.session.add(new_event)
    db.session.commit()
    return jsonify({'message': 'Evento criado com sucesso!'}), 201

@app.route('/events/<int:event_id>', methods=['PUT', 'OPTIONS'])
def update_event(event_id):
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'}), 200
    
    data = request.json
    event_to_update = Event.query.get_or_404(event_id)
    event_to_update.title = data.get('title', event_to_update.title)
    event_to_update.description = data.get('description', event_to_update.description)
    event_to_update.date = data.get('date', event_to_update.date)
    event_to_update.time = data.get('time', event_to_update.time)
    db.session.commit()
    return jsonify({'message': f'Evento {event_id} atualizado com sucesso!'})

@app.route('/events/<int:event_id>', methods=['DELETE', 'OPTIONS'])
def delete_event(event_id):
    if request.method == 'OPTIONS':
        return jsonify({'status': 'ok'}), 200
        
    event_to_delete = Event.query.get_or_404(event_id)
    db.session.delete(event_to_delete)
    db.session.commit()
    return jsonify({'message': f'Evento {event_id} deletado com sucesso!'})

@app.route('/subscribe/<int:event_id>', methods=['POST'])
def subscribe(event_id):
    user_id = session.get('user_id')
    if not user_id:
        return jsonify({'error': 'Não autenticado.'}), 403

    user = User.query.get(user_id)
    event = Event.query.get_or_404(event_id)
    
    if event not in user.subscribed_events:
        user.subscribed_events.append(event)
        db.session.commit()

    return jsonify({'message': f'Inscrito com sucesso no evento {event.title}!'})

@app.route('/my_agenda', methods=['GET'])
def my_agenda():
    user_id = session.get('user_id')
    if not user_id:
        return jsonify({'error': 'Não autenticado.'}), 403

    user = User.query.get(user_id)
    events = user.subscribed_events
    events_list = [{'id': e.id, 'title': e.title, 'date': e.date} for e in events]
    return jsonify(events_list)

@app.route('/event/<int:event_id>/question', methods=['POST'])
def post_question(event_id):
    user_id = session.get('user_id')
    if not user_id:
        return jsonify({'error': 'Não autenticado.'}), 403
    
    data = request.json
    user = User.query.get(user_id)
    event = Event.query.get_or_404(event_id)
    
    new_question = Question(content=data.get('content'), author=user, event=event)
    db.session.add(new_question)
    db.session.commit()
    
    return jsonify({'message': 'Pergunta enviada com sucesso!'}), 201