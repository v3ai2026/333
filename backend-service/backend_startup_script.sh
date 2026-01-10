#!/bin/bash
set -e

# ============================================
# MagicAI 后端服务启动脚本
# 在 Google Compute Engine 实例上运行
# ============================================

echo "🚀 开始启动 MagicAI 后端服务..."

# 1. 设置环境变量
export GCP_PROJECT_ID="gen-lang-client-0654563230"
export GCP_REGION="us-central1"
export MODEL_ID="gemini-pro"
export PORT="8080"

echo "📝 环境变量已设置"
echo "   项目ID: $GCP_PROJECT_ID"
echo "   区域: $GCP_REGION"
echo "   模型: $MODEL_ID"

# 2. 更新系统包
echo "📦 更新系统包..."
apt-get update -y
apt-get upgrade -y

# 3. 安装 Python 和依赖工具
echo "🐍 安装 Python3..."
apt-get install -y python3 python3-pip python3-venv git curl

# 4. 克隆或拉取后端代码
REPO_URL="https://github.com/v3ai2026/MagicAI-v9.9.git"
APP_DIR="/opt/magicai-backend"

echo "📥 克隆后端代码..."
if [ -d "$APP_DIR" ]; then
    echo "   目录已存在，更新代码..."
    cd "$APP_DIR"
    git pull origin main
else
    echo "   克隆新代码..."
    git clone "$REPO_URL" "$APP_DIR"
    cd "$APP_DIR"
fi

# 5. 进入后端服务目录
cd "$APP_DIR/backend-service"

# 6. 创建虚拟环境
echo "🔧 创建 Python 虚拟环境..."
python3 -m venv venv
source venv/bin/activate

# 7. 安装 Python 依赖
echo "📚 安装 Python 依赖..."
pip install --upgrade pip
pip install -r requirements.txt

# 8. 创建 .env 文件（如果不存在）
echo "⚙️  配置环境文件..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "   created .env from .env.example"
fi

# 9. 配置 Systemd 服务
echo "🔨 配置 Systemd 服务..."

cat > /etc/systemd/system/magicai-backend.service << 'EOF'
[Unit]
Description=MagicAI Backend Service
After=network.target
Wants=network-online.target

[Service]
Type=notify
User=www-data
WorkingDirectory=/opt/magicai-backend/backend-service
Environment="PATH=/opt/magicai-backend/backend-service/venv/bin"
Environment="GCP_PROJECT_ID=gen-lang-client-0654563230"
Environment="GCP_REGION=us-central1"
Environment="MODEL_ID=gemini-pro"
Environment="PORT=8080"
ExecStart=/opt/magicai-backend/backend-service/venv/bin/gunicorn \
    --bind 0.0.0.0:8080 \
    --workers 4 \
    --threads 2 \
    --worker-class gthread \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 10. 启用并启动服务
echo "▶️  启动 Systemd 服务..."
systemctl daemon-reload
systemctl enable magicai-backend.service
systemctl start magicai-backend.service

# 11. 配置 Nginx 反向代理（可选）
echo "🌐 配置 Nginx 反向代理..."
apt-get install -y nginx

cat > /etc/nginx/sites-available/magicai-backend << 'EOF'
server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超时配置
        proxy_connect_timeout 120s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
    }

    # 健康检查端点
    location /health {
        proxy_pass http://127.0.0.1:8080/health;
        access_log off;
    }
}
EOF

# 启用站点
if [ ! -L /etc/nginx/sites-enabled/magicai-backend ]; then
    ln -s /etc/nginx/sites-available/magicai-backend /etc/nginx/sites-enabled/
fi

# 删除默认站点配置（可选）
rm -f /etc/nginx/sites-enabled/default

# 测试 Nginx 配置
nginx -t

# 启动 Nginx
systemctl enable nginx
systemctl restart nginx

# 12. 等待服务启动
echo "⏳ 等待服务启动..."
sleep 5

# 13. 验证服务状态
echo "✅ 验证服务状态..."
if systemctl is-active --quiet magicai-backend; then
    echo "✅ MagicAI 后端服务已启动"
else
    echo "❌ MagicAI 后端服务启动失败，查看日志："
    systemctl status magicai-backend
fi

if systemctl is-active --quiet nginx; then
    echo "✅ Nginx 已启动"
else
    echo "❌ Nginx 启动失败"
fi

# 14. 显示启动信息
echo ""
echo "=========================================="
echo "🎉 MagicAI 后端服务安装完成！"
echo "=========================================="
echo ""
echo "📍 服务信息："
echo "   服务名称: magicai-backend"
echo "   监听端口: 8080 (Gunicorn)"
echo "   Nginx 端口: 80"
echo "   应用目录: $APP_DIR"
echo ""
echo "📋 常用命令："
echo "   查看服务状态: systemctl status magicai-backend"
echo "   查看服务日志: journalctl -u magicai-backend -f"
echo "   重启服务: systemctl restart magicai-backend"
echo "   更新代码: cd $APP_DIR && git pull origin main"
echo ""
echo "🧪 测试请求："
echo "   curl http://localhost/health"
echo "   curl -X POST http://localhost/api/chat -H 'Content-Type: application/json' -d '{\"question\": \"你好\"}'"
echo ""
echo "=========================================="
