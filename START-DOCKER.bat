@echo off
REM MagicAI v9.9 快速启动脚本
REM 运行此脚本启动所有服务

echo ========================================
echo  MagicAI v9.9 部署启动脚本
echo ========================================
echo.

REM 检查 Docker 是否运行
docker version > nul 2>&1
if errorlevel 1 (
    echo ❌ Docker 未运行！
    echo 请先启动 Docker Desktop 应用，然后重新运行此脚本
    echo.
    pause
    exit /b 1
)

echo ✓ Docker 已检测
echo.

REM 进入 MagicAI 目录
cd /d "c:\Users\Administrator\Desktop\MagicAI v9.9"

echo 正在启动 Docker Compose...
echo.

REM 启动所有服务
docker-compose up -d

echo.
echo ========================================
echo  启动完成！服务正在运行中...
echo ========================================
echo.
echo 📊 服务状态：
docker-compose ps
echo.
echo 🌐 访问地址：
echo    Web UI:      http://localhost:8000
echo    Python API:  http://localhost:8080
echo    MySQL:       localhost:3306
echo    Redis:       localhost:6379
echo.
echo 📝 查看日志：
echo    docker-compose logs -f web
echo.
echo 🛑 停止服务：
echo    docker-compose down
echo.
pause
