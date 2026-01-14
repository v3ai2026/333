"""
MagicAI Backend Service - Python Microservice for AI/ML Workloads
Handles Vertex AI integration, GCP services, and async AI processing
"""

import os
import json
import logging
from flask import Flask, request, jsonify
from functools import wraps
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

# Configuration
GCP_PROJECT_ID = os.getenv('GCP_PROJECT_ID', 'default-project')
GCP_REGION = os.getenv('GCP_REGION', 'us-central1')
VERTEX_AI_ENABLED = os.getenv('VERTEX_AI_ENABLED', 'false').lower() == 'true'

# Error handler decorator


def handle_errors(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception as e:
            logger.error(f"Error in {f.__name__}: {str(e)}")
            return jsonify({
                'error': str(e),
                'status': 'error',
                'timestamp': datetime.utcnow().isoformat()
            }), 500
    return decorated_function

# ============================================================================
# HEALTH & STATUS ENDPOINTS
# ============================================================================


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for Docker and monitoring"""
    return jsonify({
        'status': 'healthy',
        'service': 'MagicAI Backend',
        'version': '9.9.0',
        'timestamp': datetime.utcnow().isoformat(),
        'gcp_project': GCP_PROJECT_ID,
        'region': GCP_REGION
    }), 200


@app.route('/status', methods=['GET'])
def status():
    """Detailed service status"""
    return jsonify({
        'status': 'operational',
        'service': 'MagicAI Python Backend',
        'uptime_timestamp': datetime.utcnow().isoformat(),
        'environment': {
            'GCP_PROJECT_ID': GCP_PROJECT_ID,
            'GCP_REGION': GCP_REGION,
            'VERTEX_AI_ENABLED': VERTEX_AI_ENABLED,
            'PYTHON_VERSION': '3.11'
        }
    }), 200


@app.route('/api/status', methods=['GET'])
def api_status():
    """API status for legacy compatibility"""
    return jsonify({
        'service': 'MagicAI Backend',
        'version': '9.9.0',
        'status': 'running'
    }), 200

# ============================================================================
# AI/ML PROCESSING ENDPOINTS
# ============================================================================


@app.route('/api/ai/process', methods=['POST'])
@handle_errors
def process_ai_request():
    """
    Process AI/ML requests (Vertex AI integration placeholder)
    """
    data = request.get_json()

    if not data or 'model' not in data:
        return jsonify({'error': 'Missing required field: model'}), 400

    model = data.get('model')
    input_data = data.get('input', {})
    parameters = data.get('parameters', {})

    logger.info(f"Processing AI request for model: {model}")

    return jsonify({
        'status': 'success',
        'message': f'AI request processed for model: {model}',
        'model': model,
        'input_size': len(json.dumps(input_data)),
        'parameters': parameters,
        'processing_timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/api/ai/chat', methods=['POST'])
@handle_errors
def process_chat():
    """Process chat requests through Vertex AI"""
    data = request.get_json()

    if not data or 'message' not in data:
        return jsonify({'error': 'Missing required field: message'}), 400

    message = data.get('message')
    conversation_id = data.get('conversation_id', 'default')
    model = data.get('model', 'gemini-pro')

    logger.info(f"Chat request for conversation: {conversation_id}")

    return jsonify({
        'status': 'success',
        'message': message,
        'response': f'Processed by {model}',
        'conversation_id': conversation_id,
        'timestamp': datetime.utcnow().isoformat()
    }), 200

# ============================================================================
# ASYNC JOB ENDPOINTS
# ============================================================================


@app.route('/api/jobs/submit', methods=['POST'])
@handle_errors
def submit_job():
    """Submit async job for background processing"""
    data = request.get_json()

    if not data or 'job_type' not in data:
        return jsonify({'error': 'Missing required field: job_type'}), 400

    job_type = data.get('job_type')
    payload = data.get('payload', {})

    job_id = f"job_{int(datetime.utcnow().timestamp() * 1000)}"

    logger.info(f"Job submitted: {job_id} (type: {job_type}, payload: {payload})")

    return jsonify({
        'status': 'submitted',
        'job_id': job_id,
        'job_type': job_type,
        'created_at': datetime.utcnow().isoformat()
    }), 202


@app.route('/api/jobs/<job_id>', methods=['GET'])
@handle_errors
def get_job_status(job_id):
    """Get status of async job"""
    logger.info(f"Status check for job: {job_id}")

    return jsonify({
        'job_id': job_id,
        'status': 'pending',
        'progress': 0,
        'last_updated': datetime.utcnow().isoformat()
    }), 200

# ============================================================================
# ERROR HANDLERS
# ============================================================================


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Endpoint not found',
        'status': 404,
        'path': request.path
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal Server Error: {str(error)}")
    return jsonify({
        'error': 'Internal server error',
        'status': 500
    }), 500

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    debug = os.getenv('APP_DEBUG', 'false').lower() == 'true'

    logger.info(f"Starting MagicAI Backend Service on port {port}")
    logger.info(f"GCP Project: {GCP_PROJECT_ID}, Region: {GCP_REGION}")

    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug,
        threaded=True
    )
