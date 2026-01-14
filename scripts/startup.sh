#!/bin/bash

# moda.STUDIO 一键启动脚本（Linux/Mac）

set -e

cd "$(dirname "$0")"

echo ""
echo "===================================="
echo "  moda.STUDIO - 全栈启动工具"
echo "===================================="
echo ""

# 检查依赖
echo "[1/5] 检查依赖..."

if ! command -v php &> /dev/null; then
    echo "❌ PHP 未安装"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 未安装"
    exit 1
fi

echo "✅ 依赖检查完成"

# 配置端点 1: 数据库
echo ""
echo "[2/5] 检查 MySQL..."
if command -v mysql &> /dev/null; then
    echo "✅ MySQL 已就绪 - 端点 1: localhost:3306"
else
    echo "⚠️  MySQL 未运行 - 请确保 MySQL 服务启动"
fi

# 配置端点 2: Laravel 前端
echo ""
echo "[3/5] 准备 Laravel 后端服务..."
cd server

if [ ! -d vendor ]; then
    echo "安装 Composer 依赖..."
    composer install --no-dev
fi

if [ ! -d node_modules ]; then
    echo "安装 NPM 依赖..."
    npm install
fi

if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate
fi

echo "✅ Laravel 已准备 - 端点 2: http://localhost:8000"

# 配置端点 3: Python 后端
echo ""
echo "[4/5] 准备 Python 后端服务..."
cd ../backend-service

if [ ! -d venv ]; then
    echo "创建 Python 虚拟环境..."
    python3 -m venv venv
fi

echo "激活虚拟环境..."
source venv/bin/activate

echo "安装 Python 依赖..."
pip install -r requirements.txt > /dev/null 2>&1

echo "✅ Python 后端已准备 - 端点 3: http://localhost:8080"

cd ..

# 启动各个服务
echo ""
echo "===================================="
echo "  启动所有服务..."
echo "===================================="
echo ""

# 端点 2: Laravel (8000)
echo "🚀 启动 Laravel 服务 (http://localhost:8000)..."
cd server
php artisan serve --port=8000 &
LARAVEL_PID=$!

# 端点 3: Python (8080)
echo "🚀 启动 Python 后端 (http://localhost:8080)..."
cd ../backend-service
source venv/bin/activate
python app.py &
PYTHON_PID=$!

cd ..

# 等待服务启动
sleep 3

echo ""
echo "===================================="
echo "  ✅ moda.STUDIO 已启动！"
echo "===================================="
echo ""
echo "📍 可用端点:"
echo "   1️⃣  数据库:     mysql://localhost:3306"
echo "   2️⃣  前端:       http://localhost:8000"
echo "   3️⃣  后端:       http://localhost:8080"
echo "   4️⃣  API:        http://localhost:8000/api"
echo "   5️⃣  仪表板:     http://localhost:8000/admin"
echo ""
echo "💡 提示:"
echo "   - 按 Ctrl+C 停止服务"
echo "   - 首次运行请执行: php artisan migrate --seed"
echo ""
echo "===================================="

# 捕获 Ctrl+C 信号
trap "kill $LARAVEL_PID $PYTHON_PID; exit" SIGINT

# 等待进程完成
wait
