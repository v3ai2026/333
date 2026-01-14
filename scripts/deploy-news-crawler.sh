#!/bin/bash

# ==========================================
# moda.STUDIO 新闻爬虫系统 - 自动化部署脚本
# ==========================================

set -e

echo "🚀 开始部署 moda.STUDIO 新闻爬虫系统..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_PATH="/var/www/moda.STUDIO"
LOG_PATH="/var/log/moda.STUDIO"

# 创建日志目录
mkdir -p "$LOG_PATH"

echo -e "${BLUE}=== 第 1 步：环境检查 ===${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}❌ PHP 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PHP: $(php -v | head -n 1)${NC}"

if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ MySQL 已安装${NC}"

if ! command -v redis-cli &> /dev/null; then
    echo -e "${YELLOW}⚠ Redis 未安装（可选，推荐安装）${NC}"
else
    echo -e "${GREEN}✓ Redis 已安装${NC}"
fi

echo -e "${BLUE}=== 第 2 步：数据库迁移 ===${NC}"
cd "$PROJECT_PATH/server"

# 运行迁移
php artisan migrate --force >> "$LOG_PATH/setup.log" 2>&1
echo -e "${GREEN}✓ 数据库迁移完成${NC}"

# 运行 seeder
php artisan db:seed --class=NewsSourceSeeder --force >> "$LOG_PATH/setup.log" 2>&1
echo -e "${GREEN}✓ 新闻源初始化完成${NC}"

echo -e "${BLUE}=== 第 3 步：配置守护进程 ===${NC}"

# 创建 Supervisor 配置
cat > /etc/supervisor/conf.d/moda-news-crawler.conf << 'EOF'
; moda.STUDIO 新闻爬虫队列工作进程
[program:moda-news-crawler]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/moda.STUDIO/server/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
numprocs=2
redirect_stderr=true
stdout_logfile=/var/log/moda.STUDIO/queue-worker.log
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5
startsecs=10
stopwaitsecs=3600

; moda.STUDIO 定时任务调度
[program:moda-schedule]
process_name=%(program_name)s
command=php /var/www/moda.STUDIO/server/artisan schedule:work
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
redirect_stderr=true
stdout_logfile=/var/log/moda.STUDIO/schedule.log
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5
startsecs=10

[group:moda-studio]
programs=moda-news-crawler,moda-schedule
priority=999
EOF

echo -e "${GREEN}✓ Supervisor 配置已创建${NC}"

# 重新加载 Supervisor
supervisorctl reread >> "$LOG_PATH/setup.log" 2>&1
supervisorctl update >> "$LOG_PATH/setup.log" 2>&1
echo -e "${GREEN}✓ Supervisor 已更新${NC}"

# 启动服务
supervisorctl start moda-studio:* >> "$LOG_PATH/setup.log" 2>&1
echo -e "${GREEN}✓ moda-studio 服务已启动${NC}"

echo -e "${BLUE}=== 第 4 步：配置 Cron 定时任务 ===${NC}"

# 检查是否已存在
if ! crontab -l 2>/dev/null | grep -q "moda-schedule"; then
    # 添加 cron 任务（备用方案）
    (crontab -l 2>/dev/null; echo "* * * * * cd /var/www/moda.STUDIO/server && php artisan schedule:run >> /var/log/moda.STUDIO/schedule-cron.log 2>&1") | crontab -
    echo -e "${GREEN}✓ Cron 定时任务已配置${NC}"
else
    echo -e "${GREEN}✓ Cron 定时任务已存在${NC}"
fi

echo -e "${BLUE}=== 第 5 步：配置日志轮转 ===${NC}"

# 创建 logrotate 配置
cat > /etc/logrotate.d/moda-studio << 'EOF'
/var/log/moda.STUDIO/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0644 www-data www-data
    sharedscripts
    postrotate
        supervisorctl reread > /dev/null 2>&1 || true
    endscript
}
EOF

echo -e "${GREEN}✓ 日志轮转已配置${NC}"

echo -e "${BLUE}=== 第 6 步：启动自动爬取 ===${NC}"

# 立即执行第一次爬取
cd "$PROJECT_PATH/server"
php artisan news:crawl >> "$LOG_PATH/crawl-initial.log" 2>&1 &
echo -e "${GREEN}✓ 首次爬取已启动（后台运行）${NC}"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ moda.STUDIO 新闻爬虫系统部署完成！${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "📊 服务状态："
supervisorctl status moda-studio:*
echo ""
echo "📝 日志位置："
echo "   队列工作进程: $LOG_PATH/queue-worker.log"
echo "   定时调度: $LOG_PATH/schedule.log"
echo "   爬虫日志: $LOG_PATH/crawl-initial.log"
echo ""
echo "🔧 常用命令："
echo "   查看状态: supervisorctl status moda-studio:*"
echo "   重启服务: supervisorctl restart moda-studio:*"
echo "   查看日志: tail -f $LOG_PATH/queue-worker.log"
echo "   手动爬取: cd $PROJECT_PATH/server && php artisan news:crawl"
echo ""
