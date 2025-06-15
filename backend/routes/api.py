# Файл: backend/routes/api.py
from flask import Blueprint, request, jsonify
from models.user import User

api_bp = Blueprint('api', __name__)

@api_bp.route('/users', methods=['GET'])
def get_users():
    """Връща всички потребители"""
    try:
        users = User.get_all()
        return jsonify([user.to_dict() for user in users])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Връща потребител по ID"""
    try:
        user = User.get_by_id(user_id)
        if user:
            return jsonify(user.to_dict())
        return jsonify({'error': 'User not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/users', methods=['POST'])
def create_user():
    """Създава нов потребител"""
    try:
        data = request.get_json()
        
        if not data or not data.get('name') or not data.get('email'):
            return jsonify({'error': 'Name and email are required'}), 400
        
        user = User(name=data['name'], email=data['email'])
        user.save()
        
        return jsonify(user.to_dict()), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/stats', methods=['GET'])
def get_stats():
    """Връща статистики за приложението"""
    try:
        users = User.get_all()
        return jsonify({
            'total_users': len(users),
            'app_name': 'Microservices App',
            'version': '1.0.0'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500