@echo off
REM MagicAI v9.9 快速部署脚本 (Windows)
REM 自动化设置和启动 Docker 容器

setlocal enabledelayedexpansion

cls
echo ════════════════════════════════════════════════════════════════
echo   MagicAI v9.9 快速部署 (Windows)
echo ════════════════════════════════════════════════════════════════
echo.

REM 检查 Docker
docker --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo ✗ Docker 未安装或不在 PATH 中
    color 07
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo ✗ Docker Compose 未安装
    color 07
    pause
    exit /b 1
)

color 0A
echo ✓ Docker 已安装
color 07
echo.

REM 1. 创建环境配置
echo 1. 配置环境变量...
if not exist .env (
    copy .env.example .env >nul
    color 0A
    echo ✓ 创建 .env 文件
    color 07
) else (
    color 0E
    echo ⚠ .env 文件已存在，跳过
    color 07
)

REM 2. backend-service 环境配置
if not exist backend-service\.env (
    copy backend-service\.env.example backend-service\.env >nul
    color 0A
    echo ✓ 创建 backend-service\.env
    color 07
)
echo.

REM 3. 构建镜像
echo 2. 构建 Docker 镜像...
docker-compose build --no-cache
if errorlevel 1 (
    color 0E
    echo ⚠ 构建过程中有警告
    color 07
)
color 0A
echo ✓ 镜像构建完成
color 07
echo.

REM 4. 启动服务
echo 3. 启动容器...
docker-compose up -d
if errorlevel 1 (
    color 0C
    echo ✗ 启动失败
    color 07
    pause
    exit /b 1
)
color 0A
echo ✓ 容器已启动
color 07
echo.

REM 5. 等待数据库
echo 4. 等待数据库初始化...
setlocal enabledelayedexpansion
for /L %%i in (1,1,30) do (
    docker-compose exec -T db mysqladmin ping -u root -psecret >nul 2>&1
    if errorlevel 0 (
        color 0A
        echo ✓ 数据库已就绪
        color 07
        goto db_ready
    )
    echo ⏳ 等待中... (%%i/30)
    timeout /t 1 /nobreak >nul
)

:db_ready
echo.

REM 6. 运行迁移
echo 5. 运行数据库迁移...
docker-compose exec -T web php artisan key:generate >nul 2>&1
docker-compose exec -T web php artisan migrate --force >nul 2>&1
if errorlevel 1 (
    color 0E
    echo ⚠ 迁移可能已运行
    color 07
) else (
    color 0A
    echo ✓ 迁移完成
    color 07
)
echo.

REM 7. 编译前端
echo 6. 编译前端资源...
docker-compose exec -T web npm run build >nul 2>&1
if errorlevel 1 (
    color 0E
    echo ⚠ 前端编译有问题
    color 07
) else (
    color 0A
    echo ✓ 前端资源编译完成
    color 07
)
echo.

REM 8. 验证服务
echo 7. 验证服务状态...

REM Web 应用
timeout /t 2 /nobreak >nul
echo.
curl -s http://localhost:8000/health >nul 2>&1
if errorlevel 0 (
    echo   ✓ Web 应用就绪
) else (
    echo   ⏳ Web 应用初始化中
)

REM Python 后端
curl -s http://localhost:8080/health >nul 2>&1
if errorlevel 0 (
    echo   ✓ Python 后端就绪
) else (
    echo   ⏳ Python 后端初始化中
)

echo.
echo ════════════════════════════════════════════════════════════════
color 0A
echo ✓ 部署完成！
color 07
echo ════════════════════════════════════════════════════════════════
echo.

echo 📍 访问地址:
echo    🌐 Web 应用: http://localhost:8000
echo    📚 API 文档: http://localhost:8000/api/documentation
echo    🔧 后端 API: http://localhost:8080/status
echo    💾 数据库: localhost:3306 ^(user: magicai^)
echo    🔴 Redis: localhost:6379
echo.

echo 📋 有用的命令:
echo    查看日志:      docker-compose logs -f
echo    进入容器:      docker-compose exec web bash
echo    停止服务:      docker-compose down
echo    重启服务:      docker-compose restart
echo.

echo 🔐 关键配置:
echo    编辑配置文件: notepad .env
echo    查看日志:     docker-compose logs
echo.

echo ⏰ 约需 2-3 分钟才能完全初始化
echo.
pause
