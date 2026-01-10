#!/bin/bash
# moda.STUDIO - 自动爬虫机器人启动验证脚本
# 验证所有自动机器人是否正常运行

echo "════════════════════════════════════════════════════════════"
echo "🤖 moda.STUDIO 自动爬虫机器人启动验证"
echo "════════════════════════════════════════════════════════════"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. 检查 Docker 服务状态
echo "📋 步骤 1: 检查 Docker 服务状态"
echo "─────────────────────────────────────────────"

services=("db" "redis" "web" "python-backend" "queue-worker" "news-crawler" "scheduler")
all_running=true

for service in "${services[@]}"; do
  status=$(docker-compose ps --services --filter "status=running" | grep -w "$service" || echo "")
  if [ ! -z "$status" ]; then
    echo -e "${GREEN}✓${NC} $service (运行中)"
  else
    echo -e "${RED}✗${NC} $service (已停止)"
    all_running=false
  fi
done

if [ "$all_running" = true ]; then
  echo -e "\n${GREEN}✓ 所有服务已启动${NC}\n"
else
  echo -e "\n${RED}✗ 某些服务未启动，请检查${NC}\n"
  echo "运行以下命令启动："
  echo "  docker-compose up -d"
  exit 1
fi

# 2. 验证数据库连接
echo ""
echo "📋 步骤 2: 验证数据库连接"
echo "─────────────────────────────────────────────"

db_test=$(docker exec modastudio-db mysql -u magicai -psecret -e "SELECT 1" 2>/dev/null)
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓${NC} MySQL 数据库连接正常"
else
  echo -e "${RED}✗${NC} MySQL 数据库连接失败"
  exit 1
fi

# 3. 验证 Redis 连接
echo ""
echo "📋 步骤 3: 验证 Redis 连接"
echo "─────────────────────────────────────────────"

redis_test=$(docker exec modastudio-redis redis-cli ping 2>/dev/null)
if [ "$redis_test" = "PONG" ]; then
  echo -e "${GREEN}✓${NC} Redis 连接正常"
else
  echo -e "${RED}✗${NC} Redis 连接失败"
  exit 1
fi

# 4. 检查爬虫机器人日志
echo ""
echo "📋 步骤 4: 检查爬虫机器人日志"
echo "─────────────────────────────────────────────"

crawler_logs=$(docker logs --tail 10 modastudio-news-crawler 2>/dev/null | tail -1)
if [ ! -z "$crawler_logs" ]; then
  echo -e "${GREEN}✓${NC} 爬虫机器人正在运行"
  echo "   最近日志: ${crawler_logs:0:80}..."
else
  echo -e "${YELLOW}⚠${NC}  爬虫机器人暂无日志输出"
fi

# 5. 检查调度器
echo ""
echo "📋 步骤 5: 检查调度器状态"
echo "─────────────────────────────────────────────"

scheduler_logs=$(docker logs --tail 10 modastudio-scheduler 2>/dev/null | tail -1)
if [ ! -z "$scheduler_logs" ]; then
  echo -e "${GREEN}✓${NC} 调度器正在运行"
  echo "   最近日志: ${scheduler_logs:0:80}..."
else
  echo -e "${YELLOW}⚠${NC}  调度器暂无日志输出"
fi

# 6. 检查数据库中的新闻数量
echo ""
echo "📋 步骤 6: 检查数据库中的新闻数量"
echo "─────────────────────────────────────────────"

news_count=$(docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news;" 2>/dev/null)
if [ ! -z "$news_count" ]; then
  echo -e "${GREEN}✓${NC} 数据库中有 $news_count 条新闻"
else
  echo -e "${YELLOW}⚠${NC}  无法读取新闻数量"
fi

# 7. 检查新闻源配置
echo ""
echo "📋 步骤 7: 检查新闻源配置"
echo "─────────────────────────────────────────────"

sources=$(docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news_sources;" 2>/dev/null)
enabled=$(docker exec modastudio-db mysql -u magicai -psecret magicai -se "SELECT COUNT(*) FROM news_sources WHERE status='enabled';" 2>/dev/null)

echo -e "${GREEN}✓${NC} 总共配置了 $sources 个新闻源"
echo "   启用的源: $enabled 个"

# 8. 检查爬虫日志统计
echo ""
echo "📋 步骤 8: 最近的爬虫执行日志"
echo "─────────────────────────────────────────────"

# 获取最近 5 条日志
docker exec modastudio-db mysql -u magicai -psecret magicai -e \
  "SELECT 
    DATE_FORMAT(executed_at, '%Y-%m-%d %H:%i:%s') as 时间,
    status as 状态,
    articles_found as 发现,
    articles_saved as 保存
   FROM news_crawler_logs 
   ORDER BY executed_at DESC 
   LIMIT 5;" 2>/dev/null | head -6

# 9. 性能统计
echo ""
echo "📋 步骤 9: 容器资源使用情况"
echo "─────────────────────────────────────────────"

echo "爬虫机器人资源占用:"
docker stats --no-stream modastudio-news-crawler --format "table {{.Container}}\t{{.MemUsage}}\t{{.CPUPerc}}" 2>/dev/null || echo "  (无法获取)"

# 10. API 测试
echo ""
echo "📋 步骤 10: API 端点测试"
echo "─────────────────────────────────────────────"

# 检查 web 服务是否可访问
web_test=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/news 2>/dev/null)
if [ "$web_test" = "401" ] || [ "$web_test" = "200" ]; then
  echo -e "${GREEN}✓${NC} API 端点响应正常 (HTTP $web_test)"
else
  echo -e "${YELLOW}⚠${NC}  API 端点响应异常 (HTTP $web_test)"
fi

# 最终总结
echo ""
echo "════════════════════════════════════════════════════════════"
echo "✅ 验证完成"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📝 接下来可以做的事情:"
echo ""
echo "1️⃣  实时查看爬虫日志:"
echo "    docker logs -f modastudio-news-crawler"
echo ""
echo "2️⃣  查看调度器执行情况:"
echo "    docker logs -f modastudio-scheduler"
echo ""
echo "3️⃣  查看数据库数据:"
echo "    docker exec -it modastudio-db mysql -u magicai -psecret magicai"
echo ""
echo "4️⃣  测试爬虫命令 (手动):"
echo "    docker exec modastudio-web php artisan news:crawl"
echo ""
echo "5️⃣  查看 Web UI:"
echo "    http://localhost:8000"
echo ""
echo "6️⃣  查看新闻 API:"
echo "    http://localhost:8000/api/news"
echo ""
echo "🤖 moda.STUDIO 自动爬虫机器人已启动！"
echo "════════════════════════════════════════════════════════════"
