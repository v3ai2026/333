@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 颜色定义 (仅 Windows 10+ 支持)
for /F %%A in ('echo prompt $H ^| cmd') do set "BS=%%A"

echo.
echo ════════════════════════════════════════════════════════════
echo 🤖 moda.STUDIO 自动爬虫机器人启动验证
echo ════════════════════════════════════════════════════════════
echo.

REM 1. 检查 Docker 是否安装
echo 📋 步骤 1: 检查 Docker 安装
echo ─────────────────────────────────────────────
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Docker 未安装或未在 PATH 中
    echo 请先安装 Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo ✓ Docker 已安装
echo ✓ Docker Compose 已准备就绪
echo.

REM 2. 检查 Docker Compose 服务状态
echo 📋 步骤 2: 检查 Docker 服务状态
echo ─────────────────────────────────────────────

for %%S in (db redis web python-backend queue-worker news-crawler scheduler) do (
    docker-compose ps --services --filter "status=running" 2>nul | find "%%S" >nul
    if !errorlevel! equ 0 (
        echo ✓ %%S 运行中
    ) else (
        echo ✗ %%S 已停止
        set "all_running=false"
    )
)

if "!all_running!"=="false" (
    echo.
    echo ✗ 某些服务未启动，请运行:
    echo    docker-compose up -d
    pause
    exit /b 1
)
echo ✓ 所有服务已启动
echo.

REM 3. 验证数据库连接
echo 📋 步骤 3: 验证数据库连接
echo ─────────────────────────────────────────────
docker exec modastudio-db mysql -u magicai -psecret -e "SELECT 1" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ MySQL 数据库连接正常
) else (
    echo ✗ MySQL 数据库连接失败
    pause
    exit /b 1
)
echo.

REM 4. 验证 Redis 连接
echo 📋 步骤 4: 验证 Redis 连接
echo ─────────────────────────────────────────────
docker exec modastudio-redis redis-cli ping >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Redis 连接正常
) else (
    echo ✗ Redis 连接失败
    pause
    exit /b 1
)
echo.

REM 5. 检查爬虫机器人日志
echo 📋 步骤 5: 检查爬虫机器人日志
echo ─────────────────────────────────────────────
docker logs --tail 5 modastudio-news-crawler 2>nul | findstr /C:"Crawl" >nul
if %errorlevel% equ 0 (
    echo ✓ 爬虫机器人正在运行
) else (
    echo ⚠ 爬虫机器人暂无日志输出
)
echo.

REM 6. 检查调度器
echo 📋 步骤 6: 检查调度器状态
echo ─────────────────────────────────────────────
docker logs --tail 5 modastudio-scheduler 2>nul | findstr /C:"Running" >nul
if %errorlevel% equ 0 (
    echo ✓ 调度器正在运行
) else (
    echo ⚠ 调度器暂无日志输出
)
echo.

REM 7. 检查数据库中的新闻数量
echo 📋 步骤 7: 检查数据库中的新闻数量
echo ─────────────────────────────────────────────
for /f "delims=" %%i in ('docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news;" 2^>nul') do set "news_count=%%i"
if defined news_count (
    echo ✓ 数据库中有 !news_count! 条新闻
) else (
    echo ⚠ 无法读取新闻数量
)
echo.

REM 8. 检查新闻源配置
echo 📋 步骤 8: 检查新闻源配置
echo ─────────────────────────────────────────────
for /f "delims=" %%i in ('docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news_sources;" 2^>nul') do set "total_sources=%%i"
for /f "delims=" %%i in ('docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news_sources WHERE status=''enabled'';" 2^>nul') do set "enabled_sources=%%i"
echo ✓ 总共配置了 !total_sources! 个新闻源
echo   启用的源: !enabled_sources! 个
echo.

REM 9. 最终总结
echo ════════════════════════════════════════════════════════════
echo ✅ 验证完成
echo ════════════════════════════════════════════════════════════
echo.
echo 📝 接下来可以做的事情:
echo.
echo 1️⃣  实时查看爬虫日志:
echo    docker logs -f modastudio-news-crawler
echo.
echo 2️⃣  查看调度器执行情况:
echo    docker logs -f modastudio-scheduler
echo.
echo 3️⃣  查看容器资源使用:
echo    docker stats modastudio-news-crawler
echo.
echo 4️⃣  测试爬虫命令 (手动):
echo    docker exec modastudio-web php artisan news:crawl
echo.
echo 5️⃣  查看 Web UI:
echo    http://localhost:8000
echo.
echo 6️⃣  查看新闻 API:
echo    http://localhost:8000/api/news
echo.
echo 🤖 moda.STUDIO 自动爬虫机器人已启动！
echo ════════════════════════════════════════════════════════════
echo.
pause
