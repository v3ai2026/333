# 🤖 自动爬虫机器人 Docker 配置

## 功能说明

Docker Compose 现在包含 **3 个自动运行的机器人**，无需人工干预：

### 1️⃣ **News Crawler 机器人** (news-crawler service)
```
📰 功能：每 30 分钟自动爬取新闻
⏱️ 时间表：
  - 每 30 分钟运行一次 `php artisan news:crawl`
  - 连续运行，永不停止
📍 数据来源：
  - HackerNews (30分钟)
  - 36氪 (1小时)
  - Medium (2小时)
  - GitHub Trending
  - Reddit
  - Dev.to
  - 其他10+ 数据源
🔄 自动重启：容器崩溃时自动恢复
```

### 2️⃣ **Scheduler 调度器** (scheduler service)
```
⏱️ 功能：自动运行所有计划任务
📅 计划任务：
  - 每小时：标准新闻爬取 (crawl:sources)
  - 每天 02:00：深度新闻爬取 (crawl:deep)
  - 每天 03:00：清理过期数据 (news:cleanup)
  - 每周一 04:00：生成周报告 (news:report)
🔄 自动重启：任务失败时自动恢复
```

### 3️⃣ **Queue Worker 队列工作进程** (queue-worker service)
```
📤 功能：处理异步队列任务
⚙️ 特性：
  - 最多重试 3 次
  - 任务超时 60 秒
  - 自动故障恢复
```

## 🚀 快速启动

### 1. 一键启动所有机器人
```bash
# 启动 Docker Compose（包含所有自动机器人）
docker-compose up -d

# 验证所有服务已启动
docker-compose ps

# 输出示例：
# NAME                COMMAND              STATUS
# db                  mysql                Up (healthy)
# redis               redis-server         Up
# web                 php-fpm              Up
# python-backend      python app.py        Up
# queue-worker        php artisan queue    Up
# news-crawler        crawler loop         Up  ⭐ 爬虫机器人
# scheduler           schedule:work        Up  ⭐ 调度器
```

### 2. 查看机器人运行状态
```bash
# 查看爬虫机器人日志（实时）
docker logs -f modastudio-news-crawler

# 查看调度器日志
docker logs -f modastudio-scheduler

# 查看队列工作进程
docker logs -f modastudio-queue-worker
```

### 3. 监控爬虫进度
```bash
# 查看容器资源使用
docker stats modastudio-news-crawler

# 查看数据库中的新闻数量
docker exec modastudio-db mysql -u magicai -psecret magicai -e \
  "SELECT COUNT(*) as total_news, MAX(created_at) as latest FROM news;"
```

## 📊 爬虫工作流程

```
┌─────────────────────────────────────────────────────────┐
│         Docker Compose Up (一键启动)                      │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
   ┌─────────┐      ┌──────────┐    ┌────────────┐
   │   DB    │      │  Redis   │    │   Python   │
   │ (MySQL) │      │  (Cache) │    │  (Gemini)  │
   └─────────┘      └──────────┘    └────────────┘
        ▲                 ▲                 ▲
        │        ┌────────┴────────┐       │
        └────────┤                 │       │
                 ▼                 ▼       │
            ┌──────────────────────────┐   │
            │   Laravel (web service)  │   │
            └──────────────────────────┘   │
                 ▲        ▲        ▲       │
        ┌────────┴────────┴────────┴───────┘
        │
        ├─ news-crawler 🤖 (每30分钟)
        │   │
        │   ├─ 读取新闻源配置
        │   ├─ 爬取 RSS/API/网页
        │   ├─ AI 分析 (摘要、分类、关键词)
        │   ├─ 保存到数据库
        │   └─ 记录爬虫日志
        │
        ├─ scheduler ⏱️ (24/7 运行)
        │   │
        │   ├─ 每小时：标准爬取
        │   ├─ 每天深夜：深度爬取
        │   ├─ 每天凌晨：数据清理
        │   └─ 每周一：生成报告
        │
        └─ queue-worker ⚙️ (异步任务)
            │
            ├─ 处理异步爬虫任务
            ├─ 处理 AI 分析任务
            ├─ 失败自动重试
            └─ 错误恢复机制
```

## 🔧 配置文件位置

### Docker Compose 配置
```
docker-compose.yml
├── services:
│   ├── db (MySQL)
│   ├── redis
│   ├── web (Laravel)
│   ├── python-backend (Gemini API)
│   ├── queue-worker ⚙️ (异步处理)
│   ├── news-crawler 🤖 (爬虫机器人)
│   └── scheduler ⏱️ (调度器)
└── networks: moda-network (服务通信)
```

### 爬虫配置文件
```
server/
├── app/
│   ├── Console/
│   │   ├── Commands/
│   │   │   └── CrawlNewsCommand.php (爬虫命令)
│   │   └── Kernel.php (调度器定义)
│   ├── Services/
│   │   └── News/
│   │       └── NewsCrawlerService.php (核心爬虫逻辑)
│   ├── Jobs/
│   │   └── CrawlNewsSourceJob.php (异步爬虫任务)
│   └── Models/
│       ├── NewsSource.php (新闻源配置)
│       ├── News.php (新闻内容)
│       ├── NewsCrawlerLog.php (爬虫日志)
│       └── NewsKeyword.php (关键词)
├── database/
│   ├── migrations/
│   │   └── 2026_01_09_000001_create_news_crawler_tables.php
│   └── seeders/
│       └── NewsSourceSeeder.php (10+数据源)
└── routes/
    └── api.php (15个 API 端点)
```

## 📈 监控机器人

### 查看实时日志
```bash
# 爬虫机器人日志
docker logs -f modastudio-news-crawler 2>&1 | grep -E "Crawling|Processed|Error"

# 调度器日志
docker logs -f modastudio-scheduler 2>&1 | grep -E "Running|Scheduled|Completed"

# 队列工作进程
docker logs -f modastudio-queue-worker 2>&1 | grep -E "Processing|Completed|Failed"
```

### 查看数据库数据
```bash
# 登录数据库
docker exec -it modastudio-db bash

# 在容器内执行 MySQL
mysql -u magicai -psecret magicai

# 查看爬虫统计
SELECT 
  COUNT(*) as total_news,
  COUNT(DISTINCT news_source_id) as sources,
  MAX(created_at) as latest,
  AVG(confidence_score) as avg_confidence
FROM news;

# 查看爬虫执行日志
SELECT 
  ns.name as source,
  ncl.status,
  ncl.articles_found,
  ncl.articles_saved,
  ncl.executed_at
FROM news_crawler_logs ncl
JOIN news_sources ns ON ncl.news_source_id = ns.id
ORDER BY ncl.executed_at DESC
LIMIT 20;

# 查看活跃新闻源
SELECT 
  name,
  source_type,
  priority,
  crawl_frequency,
  status,
  last_crawled_at,
  COUNT(n.id) as articles
FROM news_sources ns
LEFT JOIN news n ON ns.id = n.news_source_id
WHERE ns.status = 'enabled'
GROUP BY ns.id
ORDER BY ns.priority DESC;
```

## 🐛 故障排查

### 爬虫机器人不运行
```bash
# 检查容器状态
docker ps -a | grep news-crawler

# 如果容器已退出，查看错误日志
docker logs modastudio-news-crawler

# 重启爬虫机器人
docker restart modastudio-news-crawler

# 查看完整日志
docker logs --tail 100 modastudio-news-crawler
```

### 数据库连接错误
```bash
# 检查 MySQL 是否正常运行
docker exec modastudio-db mysql -u magicai -psecret -e "SELECT 1"

# 检查 Redis 是否正常运行
docker exec modastudio-redis redis-cli ping
# 应该返回 PONG
```

### 爬虫任务失败
```bash
# 检查队列中的失败任务
docker exec modastudio-db mysql -u magicai -psecret magicai -e \
  "SELECT * FROM failed_jobs LIMIT 5;"

# 查看爬虫日志中的错误
docker logs modastudio-news-crawler | grep -i error

# 手动触发爬虫（用于测试）
docker exec modastudio-web php artisan news:crawl
```

### 调度器未执行任务
```bash
# 检查调度器状态
docker logs modastudio-scheduler

# 验证 Laravel Kernel.php 配置
docker exec modastudio-web php artisan schedule:list

# 查看所有计划任务
docker exec modastudio-web php artisan tinker
>>> \App\Console\Kernel::class
```

## 🚨 性能优化

### 1. 调整爬虫频率
编辑 `server/app/Console/Kernel.php`：
```php
protected function schedule(Schedule $schedule)
{
    // 改变爬虫间隔（默认30分钟）
    $schedule->command('news:crawl')
        ->everyThirtyMinutes()  // 改为 hourly(), everyTwoHours() 等
        ->withoutOverlapping();
}
```

### 2. 并行爬取多个源
编辑 `docker-compose.yml`，复制 news-crawler 服务：
```yaml
news-crawler-1:
  # ... (服务配置)
  environment:
    CRAWLER_SOURCE: hackernews
    
news-crawler-2:
  # ... (服务配置)
  environment:
    CRAWLER_SOURCE: medium
```

### 3. 增加 Redis 缓存
```yaml
redis:
  image: redis:7
  command: redis-server --maxmemory 1gb --maxmemory-policy allkeys-lru
  ports:
    - "6379:6379"
```

## 📱 API 端点查询爬虫结果

### 获取最新新闻
```bash
curl http://localhost:8000/api/news \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 响应示例：
{
  "data": [
    {
      "id": 1,
      "title": "AI突破：新型LLM超越GPT-4",
      "summary": "研究团队发布...",
      "source": "36氪",
      "category": "AI",
      "confidence_score": 0.95,
      "created_at": "2026-01-09T15:30:00Z"
    }
  ]
}
```

### 按分类查询
```bash
curl http://localhost:8000/api/news?category=AI \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 搜索关键词
```bash
curl http://localhost:8000/api/news/search?q=kubernetes \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 获取趋势新闻
```bash
curl http://localhost:8000/api/news/trending \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## ✅ 验证清单

启动后按以下步骤验证：

- [ ] `docker-compose ps` 显示所有 7 个服务都在运行
- [ ] `docker logs modastudio-news-crawler` 显示爬虫开始工作
- [ ] `docker logs modastudio-scheduler` 显示调度器已启动
- [ ] 数据库查询 `SELECT COUNT(*) FROM news;` 返回数据量递增
- [ ] API 查询 `GET /api/news` 返回最新爬取的文章
- [ ] 监控面板显示机器人运行状态
- [ ] 3 小时后检查数据库，验证爬虫确实在定期运行

## 📞 完整架构

```
用户浏览新闻
     │
     ▼
┌─────────────────┐
│   Web UI        │ ◄─── Laravel (port 8000)
│ /news           │
└─────────────────┘
     ▲
     │ API 调用
     ▼
┌─────────────────────────────────────────────────────────┐
│              Laravel 应用 (web service)                  │
│  ├─ News Controller (15个 API 端点)                     │
│  ├─ Database (news, news_sources, news_keywords...)    │
│  └─ NewsCrawlerService (核心爬虫逻辑)                  │
└─────────────────────────────────────────────────────────┘
     ▲        ▲        ▲              
     │        │        │
     │        │        └──────────────────┐
     │        │                           │
     ▼        ▼                           ▼
┌─────────┐ ┌──────────┐          ┌───────────────┐
│  MySQL  │ │  Redis   │          │ Python Gemini │
│  (Data) │ │ (Queue)  │          │   (AI API)    │
└─────────┘ └──────────┘          └───────────────┘
     ▲        ▲                           ▲
     │        │                           │
     └────────┼───────────────────────────┘
              │
    ┌─────────┼────────────┐
    │         │            │
    ▼         ▼            ▼
🤖news-     ⏱️scheduler   ⚙️queue-
crawler     (24/7)       worker
(30min)     ┌────────┐
│           │每天    │
├─ crawl    │○:00   │
├─ process  ├─ 深度  │
├─ analyze  │  爬取  │
└─ save     ├─ 数据  │
            │  清理  │
            └────────┘
```

## 🎯 总结

✅ **一键启动**：`docker-compose up -d` 即可启动所有机器人
✅ **24/7 自动运行**：爬虫机器人每 30 分钟自动爬取
✅ **智能调度**：调度器按时间表自动执行各种任务
✅ **异步处理**：队列工作进程处理繁重任务
✅ **自动恢复**：任何服务崩溃都会自动重启
✅ **完整监控**：实时日志、数据库查询、API 端点

**现在 moda.STUDIO 是一个完全自动化的 AI 新闻聚合平台！🚀**
