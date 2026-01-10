#!/bin/bash
# moda.STUDIO - 实时爬虫机器人监控仪表板
# 实时显示所有爬虫机器人的工作状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# 清屏并显示标题
clear_and_title() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                   🤖 moda.STUDIO 爬虫机器人监控仪表板                         ║
║                    Real-time Crawler Bot Dashboard                        ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# 获取容器状态
get_container_status() {
    local container=$1
    docker ps --format "{{.Names}}\t{{.Status}}" | grep "^$container" | awk '{print $2}' || echo "Not Found"
}

# 获取容器内存占用
get_memory_usage() {
    local container=$1
    docker stats --no-stream "$container" --format "{{.MemUsage}}" 2>/dev/null | head -1 || echo "N/A"
}

# 获取容器 CPU 占用
get_cpu_usage() {
    local container=$1
    docker stats --no-stream "$container" --format "{{.CPUPerc}}" 2>/dev/null | head -1 || echo "N/A"
}

# 获取最近日志行数
get_recent_logs() {
    local container=$1
    local lines=${2:-3}
    docker logs --tail $lines "$container" 2>/dev/null | tail -1 || echo "No logs"
}

# 显示服务健康状态
show_services_status() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}📋 服务状态 (Services Status)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local services=("db" "redis" "web" "python-backend" "queue-worker" "news-crawler" "scheduler")
    
    for service in "${services[@]}"; do
        local full_name="modastudio-$service"
        local status=$(get_container_status "$full_name")
        local emoji="✓"
        local color=$GREEN
        
        if [[ ! $status =~ "Up" ]]; then
            emoji="✗"
            color=$RED
        fi
        
        printf "%-15s │ ${color}%s${NC} %s\n" "$service" "$emoji" "$status"
    done
    echo ""
}

# 显示爬虫机器人详细信息
show_crawler_details() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}🤖 爬虫机器人详情 (Crawler Bot Details)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # News Crawler
    echo -e "${CYAN}📰 News Crawler 机器人${NC}"
    echo "  ├─ 名称: news-crawler"
    echo "  ├─ 功能: 每 30 分钟自动爬取新闻"
    echo "  ├─ 状态: $(get_container_status modastudio-news-crawler)"
    echo "  ├─ 内存: $(get_memory_usage modastudio-news-crawler)"
    echo "  ├─ CPU: $(get_cpu_usage modastudio-news-crawler)"
    echo -e "  └─ 最近日志: ${YELLOW}$(get_recent_logs modastudio-news-crawler)${NC}"
    echo ""
    
    # Scheduler
    echo -e "${BLUE}⏱️  Scheduler 调度器${NC}"
    echo "  ├─ 名称: scheduler"
    echo "  ├─ 功能: 24/7 运行所有计划任务"
    echo "  ├─ 状态: $(get_container_status modastudio-scheduler)"
    echo "  ├─ 内存: $(get_memory_usage modastudio-scheduler)"
    echo "  ├─ CPU: $(get_cpu_usage modastudio-scheduler)"
    echo -e "  └─ 最近日志: ${YELLOW}$(get_recent_logs modastudio-scheduler)${NC}"
    echo ""
    
    # Queue Worker
    echo -e "${GREEN}⚙️  Queue Worker 队列处理${NC}"
    echo "  ├─ 名称: queue-worker"
    echo "  ├─ 功能: 处理异步任务（爬虫、AI分析等）"
    echo "  ├─ 状态: $(get_container_status modastudio-queue-worker)"
    echo "  ├─ 内存: $(get_memory_usage modastudio-queue-worker)"
    echo "  ├─ CPU: $(get_cpu_usage modastudio-queue-worker)"
    echo -e "  └─ 最近日志: ${YELLOW}$(get_recent_logs modastudio-queue-worker)${NC}"
    echo ""
}

# 显示数据库统计信息
show_database_stats() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}📊 数据库统计 (Database Statistics)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # 新闻统计
    local news_count=$(docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news;" 2>/dev/null || echo "0")
    local today_count=$(docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news WHERE DATE(created_at) = CURDATE();" 2>/dev/null || echo "0")
    local sources_total=$(docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news_sources;" 2>/dev/null || echo "0")
    local sources_enabled=$(docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news_sources WHERE status='enabled';" 2>/dev/null || echo "0")
    
    echo -e "📰 ${WHITE}新闻数据${NC}"
    echo "  ├─ 总新闻数: ${GREEN}$news_count${NC} 篇"
    echo "  └─ 今日新闻: ${YELLOW}$today_count${NC} 篇"
    echo ""
    
    echo -e "📚 ${WHITE}新闻源配置${NC}"
    echo "  ├─ 总新闻源: ${GREEN}$sources_total${NC} 个"
    echo "  └─ 启用源: ${YELLOW}$sources_enabled${NC} 个"
    echo ""
    
    # 最近爬虫执行
    echo -e "🔄 ${WHITE}最近爬虫执行${NC}"
    docker exec modastudio-db mysql -u magicai -psecret magicai -e \
        "SELECT 
            DATE_FORMAT(executed_at, '%H:%i:%s') as 时间,
            status as 状态,
            articles_found as 发现,
            articles_saved as 保存
         FROM news_crawler_logs 
         ORDER BY executed_at DESC 
         LIMIT 3;" 2>/dev/null | tail -4 | while read line; do
        echo "  $line"
    done
    echo ""
}

# 显示最近日志
show_recent_logs() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}📝 最近活动日志 (Recent Logs)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${CYAN}News Crawler 日志:${NC}"
    docker logs --tail 5 modastudio-news-crawler 2>/dev/null | sed 's/^/  │ /' || echo "  │ No logs available"
    echo ""
    
    echo -e "${BLUE}Scheduler 日志:${NC}"
    docker logs --tail 5 modastudio-scheduler 2>/dev/null | sed 's/^/  │ /' || echo "  │ No logs available"
    echo ""
}

# 显示性能监控
show_performance() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}🎯 性能监控 (Performance Metrics)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "┌─ ${CYAN}CPU/内存使用率${NC} ─────────────────────────────────────────────────────────────┐"
    docker stats --no-stream modastudio-db modastudio-redis modastudio-news-crawler modastudio-scheduler --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | sed 's/^/  │ /'
    echo -e "└──────────────────────────────────────────────────────────────────────────────────┘"
    echo ""
}

# 显示快速命令
show_quick_commands() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}⚡ 快速命令 (Quick Commands)${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "查看实时日志:"
    echo -e "  ${CYAN}docker logs -f modastudio-news-crawler${NC}"
    echo ""
    echo "手动触发爬虫:"
    echo -e "  ${CYAN}docker exec modastudio-web php artisan news:crawl${NC}"
    echo ""
    echo "查看所有计划任务:"
    echo -e "  ${CYAN}docker exec modastudio-web php artisan schedule:list${NC}"
    echo ""
    echo "查看队列统计:"
    echo -e "  ${CYAN}docker exec modastudio-redis redis-cli -h localhost keys 'queues:*' | xargs redis-cli -h localhost llen${NC}"
    echo ""
    echo "停止所有机器人:"
    echo -e "  ${CYAN}docker-compose down${NC}"
    echo ""
    echo "重启爬虫机器人:"
    echo -e "  ${CYAN}docker restart modastudio-news-crawler${NC}"
    echo ""
}

# 显示底部信息
show_footer() {
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⏰ 更新时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${YELLOW}💡 提示: 每 30 秒自动刷新仪表板${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}按 Ctrl+C 退出监控${NC}"
}

# 主循环
main() {
    while true; do
        clear_and_title
        show_services_status
        show_crawler_details
        show_database_stats
        show_recent_logs
        show_performance
        show_quick_commands
        show_footer
        sleep 30
    done
}

# 运行主程序
main
