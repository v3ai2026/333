@echo off
REM moda.STUDIO 一键启动脚本（Windows）

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo ====================================
echo   moda.STUDIO - 全栈启动工具
echo ====================================
echo.

REM 检查依赖
echo [1/5] 检查依赖...
where php >nul 2>&1
if errorlevel 1 (
    echo ❌ PHP 未安装或不在 PATH 中
    exit /b 1
)

where node >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js 未安装或不在 PATH 中
    exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
    echo ❌ Python 未安装或不在 PATH 中
    exit /b 1
)

echo ✅ 依赖检查完成

REM 配置端点 1: 数据库
echo.
echo [2/5] 检查 MySQL...
mysql --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  MySQL 未运行 - 请确保 MySQL 服务启动
    echo    端点 1: localhost:3306 (MySQL)
) else (
    echo ✅ MySQL 已就绪 - 端点 1: localhost:3306
)

REM 配置端点 2: Laravel 前端
echo.
echo [3/5] 准备 Laravel 后端服务...
cd server

if not exist vendor (
    echo 安装 Composer 依赖...
    call composer install --no-dev
)

if not exist node_modules (
    echo 安装 NPM 依赖...
    call npm install
)

REM 生成应用密钥
if not exist .env (
    copy .env.example .env
    call php artisan key:generate
)

echo ✅ Laravel 已准备 - 端点 2: http://localhost:8000

REM 配置端点 3: Python 后端
echo.
echo [4/5] 准备 Python 后端服务...
cd ..\backend-service

if not exist venv (
    echo 创建 Python 虚拟环境...
    python -m venv venv
)

echo 激活虚拟环境...
call venv\Scripts\activate.bat

echo 安装 Python 依赖...
pip install -r requirements.txt >nul 2>&1

echo ✅ Python 后端已准备 - 端点 3: http://localhost:8080

REM 返回主目录
cd ..

REM 启动各个服务
echo.
echo ====================================
echo   启动所有服务...
echo ====================================
echo.

REM 端点 2: Laravel (8000)
echo 🚀 启动 Laravel 服务 (http://localhost:8000)...
start "moda.STUDIO - Laravel" cmd /k "cd server && php artisan serve --port=8000"

REM 端点 3: Python (8080)
echo 🚀 启动 Python 后端 (http://localhost:8080)...
cd backend-service
call venv\Scripts\activate.bat
start "moda.STUDIO - Python Backend" cmd /k "python app.py"
cd ..

REM 等待服务启动
timeout /t 3 /nobreak

echo.
echo ====================================
echo   ✅ moda.STUDIO 已启动！
echo ====================================
echo.
echo 📍 可用端点:
echo    1️⃣  数据库:     mysql://localhost:3306
echo    2️⃣  前端:       http://localhost:8000
echo    3️⃣  后端:       http://localhost:8080
echo    4️⃣  API:        http://localhost:8000/api
echo    5️⃣  仪表板:     http://localhost:8000/admin
echo.
echo 💡 提示:
echo    - 按 Ctrl+C 停止任何服务
echo    - 检查各个命令窗口的日志
echo    - 首次运行请执行: php artisan migrate --seed
echo.
echo ====================================
pause
