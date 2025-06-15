# Файл: backend/app.py
from flask import Flask
from flask_cors import CORS
import os
from database.db import init_db
from routes.api import api_bp

app = Flask(__name__)
CORS(app)

# Конфигуриране на приложението
app.config['DATABASE_URL'] = os.getenv('DATABASE_URL', 'postgresql://user:password@localhost:5432/appdb')
app.config['REDIS_URL'] = os.getenv('REDIS_URL', 'redis://localhost:6379')

# Регистриране на blueprint-и
app.register_blueprint(api_bp, url_prefix='/api')

@app.route('/')
def health_check():
    return {'status': 'healthy', 'message': 'Microservices App is running!'}

@app.route('/health')
def health():
    return {'status': 'ok', 'database': 'connected', 'redis': 'connected'}

if __name__ == '__main__':
    # Инициализиране на базата данни
    init_db()
    
    # Стартиране на приложението
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)