# FLASK BACKEND (app.py) - apenas calendário com eventos fixos
from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3

app = Flask(__name__)
CORS(app)

DB_NAME = 'calendar.db'

class DBHelper:
    def __init__(self):
        self.conn = sqlite3.connect(DB_NAME, check_same_thread=False)
        self.cursor = self.conn.cursor()
        self.create_tables()

    def create_tables(self):
        self.cursor.execute('''CREATE TABLE IF NOT EXISTS fixed_events (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                title TEXT, date TEXT, time TEXT, description TEXT)''')
        self.conn.commit()

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

@app.route('/calendar/<date>', methods=['GET'])
def get_events(date):
    rows = db.get_events_by_date(date)
    return jsonify([{'title': r[0], 'date': r[1], 'time': r[2], 'description': r[3]} for r in rows])


db.insert_sample_events()
app.run(debug=True)