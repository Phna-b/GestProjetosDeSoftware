# run.py

from app import app, db
from app.models import Event # Certifique-se que o import do modelo está correto

# O 'with app.app_context()' garante que a aplicação sabe qual banco de dados usar.
with app.app_context():
    # Cria todas as tabelas (users, events, etc.) se elas não existirem
    db.create_all()

    # Verifica se a tabela de eventos está vazia para popular com dados de exemplo
    if db.session.query(Event).count() == 0:
        print("Base de dados de eventos vazia, a inserir dados de exemplo...")

        # Cria os objetos de evento
        event1 = Event(title="Reunião mensal", date="2025-07-25", time="10:00 - 12:00", description="Reunião de alinhamento com equipe")
        event2 = Event(title="Feriado Nacional", date="2025-07-30", time="11:30 - 15:00", description="Comemoração da Liberdade Nacional")
        event3 = Event(title="Revisão de Projeto", date="2025-07-25", time="14:00 - 15:00", description="Revisar escopo do projeto XPTO")

        # Adiciona os eventos à sessão e grava no banco de dados
        db.session.add_all([event1, event2, event3])
        db.session.commit()
        print("Dados de exemplo inseridos com sucesso.")

if __name__ == '__main__':
    # Inicia o servidor Flask, escutando em todas as interfaces de rede
    app.run(host='0.0.0.0', port=5000, debug=True)