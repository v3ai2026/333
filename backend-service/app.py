# app.py - moda.STUDIO 后端智能客服服务（优化版 v2.0�?
from flask import Flask, request, jsonify
from google.cloud import aiplatform
from vertexai.preview.generative_models import GenerativeModel, Content, Part
import os
import logging
import json
import time
import hashlib
import threading
from datetime import datetime
from functools import wraps
from collections import defaultdict
from typing import Optional

app = Flask(__name__)

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 从环境变量获取配�?PROJECT_ID = os.environ.get('GCP_PROJECT_ID', 'gen-lang-client-0654563230')
REGION = os.environ.get('GCP_REGION', 'us-central1')
MODEL_ID = os.environ.get('MODEL_ID', 'gemini-2.0-flash')
PORT = int(os.environ.get('PORT', 8080))

# 缓存配置
CACHE_TTL = int(os.environ.get('CACHE_TTL', 3600))
MAX_CACHE_SIZE = int(os.environ.get('MAX_CACHE_SIZE', 500))
MAX_REQUESTS_PER_MINUTE = int(os.environ.get('MAX_REQUESTS_PER_MINUTE', 60))

# ==================== 简单缓�?====================
class Cache:
    def __init__(self):
        self.data = {}
        self.times = {}
        self.lock = threading.Lock()
    
    def key(self, q):
        return hashlib.md5(q.encode()).hexdigest()
    
    def get(self, question):
        k = self.key(question)
        with self.lock:
            if k in self.data and time.time() - self.times[k] < CACHE_TTL:
                return self.data[k]
        return None
    
    def set(self, question, answer):
        k = self.key(question)
        with self.lock:
            if len(self.data) >= MAX_CACHE_SIZE:
                oldest = min(self.times, key=self.times.get, default=k)
                if oldest in self.data:
                    del self.data[oldest]
                    del self.times[oldest]
            self.data[k] = answer
            self.times[k] = time.time()

cache = Cache()

# ==================== 速率限制 ====================
class RateLimit:
    def __init__(self, max_per_min=60):
        self.reqs = defaultdict(list)
        self.max = max_per_min
        self.lock = threading.Lock()
    
    def allow(self, client_id):
        now = time.time()
        with self.lock:
            self.reqs[client_id] = [t for t in self.reqs[client_id] if now - t < 60]
            if len(self.reqs[client_id]) < self.max:
                self.reqs[client_id].append(now)
                return True
        return False

limiter = RateLimit(max_per_min=MAX_REQUESTS_PER_MINUTE)

def rate_limit_check(f):
    @wraps(f)
    def wrapped(*args, **kwargs):
        client_id = request.remote_addr or 'unknown'
        if not limiter.allow(client_id):
            return jsonify({"error": "Too many requests. Try again later."}), 429
        return f(*args, **kwargs)
    return wrapped

# ==================== 初始�?Vertex AI ====================
try:
    aiplatform.init(project=PROJECT_ID, location=REGION)
    logger.info(f"�?Vertex AI 初始化成�? {PROJECT_ID}/{REGION}/{MODEL_ID}")
except Exception as e:
    logger.error(f"�?Vertex AI 初始化失�? {e}")

# ==================== AI 核心函数 ====================
def get_ai_response(user_question, conversation_history=None):
    """
    调用 Vertex AI 获取回复
    """
    try:
        # 1. 检查缓�?        cached = cache.get(user_question)
        if cached:
            logger.info(f"💾 缓存命中: {user_question[:30]}...")
            return cached
        
        # 2. 初始化模�?        model = GenerativeModel(MODEL_ID)
        
        # 3. 系统提示
        system_prompt = """你是一个专业的智能客服助手。你的职责是�?1. 友好、礼貌地回答用户的问�?2. 提供准确和有帮助的信�?3. 如果不知道答案，诚实地说明并建议用户联系人工客服
4. 使用用户的语言（中文或英文）进行回�?5. 回复应简洁明了，不超�?00�?""
        
        # 4. 构造请求内�?        if conversation_history:
            contents = conversation_history + [
                Content(role="user", parts=[Part.from_text(user_question)])
            ]
        else:
            contents = [
                Content(role="user", parts=[Part.from_text(system_prompt + "\n\n用户提问: " + user_question)])
            ]
        
        # 5. 调用 Vertex AI
        logger.info(f"📤 发送问题到 Vertex AI: {user_question[:50]}...")
        response = model.generate_content(
            contents=contents,
            generation_config={
                "max_output_tokens": 500,
                "temperature": 0.7,
                "top_p": 0.8,
            }
        )
        
        answer = response.text
        logger.info(f"📥 收到 AI 回复: {answer[:50]}...")
        
        # 6. 缓存结果
        cache.set(user_question, answer)
        
        return answer
        
    except Exception as e:
        logger.error(f"�?调用 Vertex AI 失败: {e}")
        return "抱歉，智能客服目前无法响应。请稍后再试或联系人工客服�?

# ==================== 路由 ====================
@app.route('/health', methods=['GET'])
def health_check():
    """健康检查端�?- Google Cloud Run 使用"""
    return jsonify({"status": "healthy"}), 200

@app.route('/', methods=['GET'])
def home():
    """主页"""
    return jsonify({
        "service": "moda.STUDIO Backend Service",
        "version": "2.0",
        "status": "running",
        "model": MODEL_ID,
        "endpoints": {
            "/health": "健康检�?,
            "/api/chat": "智能客服对话",
            "/api/v1/chat": "客服对话（V1 API�?,
            "/api/models": "模型列表"
        }
    }), 200

@app.route('/api/chat', methods=['POST'])
@rate_limit_check
def chat():
    """
    处理客服对话请求
    
    请求格式:
    {
        "question": "用户的问�?,
        "history": [...]  // 可选：对话历史
    }
    
    响应格式:
    {
        "status": "success",
        "answer": "AI的回�?,
        "timestamp": "2026-01-03T12:00:00Z"
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "请求体不能为�?}), 400
        
        user_question = data.get('question', '').strip()
        conversation_history = data.get('history', None)
        
        if not user_question:
            return jsonify({"error": "question 字段不能为空"}), 400
        
        logger.info(f"💬 处理对话请求: {user_question[:30]}...")
        
        # 调用 AI 获取回复
        ai_answer = get_ai_response(user_question, conversation_history)
        
        return jsonify({
            "status": "success",
            "answer": ai_answer,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "model": MODEL_ID
        }), 200
        
    except Exception as e:
        logger.error(f"�?处理对话时出�? {e}")
        return jsonify({
            "status": "error",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }), 500

@app.route('/api/v1/chat', methods=['POST'])
@rate_limit_check
def chat_v1():
    """V1 API - �?/api/chat 相同"""
    return chat()

@app.route('/api/models', methods=['GET'])
def list_models():
    """列出可用的模�?""
    try:
        models = [
            {"id": "gemini-2.0-flash", "name": "Gemini 2.0 Flash", "type": "text-generation"},
            {"id": "gemini-1.5-pro", "name": "Gemini 1.5 Pro", "type": "text-generation"},
        ]
        return jsonify({
            "status": "success",
            "models": models,
            "default": MODEL_ID
        }), 200
    except Exception as e:
        logger.error(f"�?列出模型失败: {e}")
        return jsonify({"status": "error", "error": str(e)}), 500

@app.errorhandler(404)
def not_found(error):
    """404 错误处理"""
    return jsonify({
        "status": "error",
        "error": "Endpoint not found",
        "available_endpoints": ["/", "/health", "/api/chat", "/api/models"]
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """500 错误处理"""
    logger.error(f"�?内部服务器错�? {error}")
    return jsonify({
        "status": "error",
        "error": "Internal server error"
    }), 500

if __name__ == '__main__':
    logger.info(f"🚀 启动 moda.STUDIO 后端服务 v2.0")
    logger.info(f"   模型: {MODEL_ID}")
    logger.info(f"   缓存: {MAX_CACHE_SIZE} items, TTL {CACHE_TTL}s")
    logger.info(f"   限制: {MAX_REQUESTS_PER_MINUTE} req/min")
    app.run(host='0.0.0.0', port=PORT, debug=False)

