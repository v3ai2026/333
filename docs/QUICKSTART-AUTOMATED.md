# 🤖 moda.STUDIO 自动爬虫启动完全指南

## 🚀 一句话总结

```bash
docker-compose up -d
```

**就这样！** 所有爬虫机器人会自动启动并 24/7 运行。

---

## 📋 三步快速启动

### 步骤 1️⃣: 打开终端

**Windows (PowerShell 或 CMD)**:
```bash
cd c:\Users\Administrator\Desktop\MagicAI v9.9
```

**Mac/Linux**:
```bash
cd ~/Desktop/MagicAI\ v9.9
```

### 步骤 2️⃣: 启动所有服务

```bash
docker-compose up -d
```

预期输出：
```
Creating modastudio-db       ... done
Creating modastudio-redis    ... done
Creating modastudio-web      ... done
Creating modastudio-python   ... done
Creating modastudio-queue-worker ... done
Creating modastudio-news-crawler ... done  ⭐ 爬虫机器人启动
Creating modastudio-scheduler    ... done  ⭐ 调度器启动
```

### 步骤 3️⃣: 验证所有机器人正常运行

```bash
# 验证脚本 (Linux/Mac)
bash verify-bots.sh

# 或 Windows
verify-bots.bat
```

---

## ✅ 验证清单

启动后逐项检查：

- [ ] **Docker 显示所有 7 个服务在运行**
  ```bash
  docker-compose ps
  ```
  
- [ ] **数据库已连接**
  ```bash
  docker exec modastudio-db mysql -u magicai -psecret -e "SELECT 1"
  ```
  
- [ ] **Redis 已连接**
  ```bash
  docker exec modastudio-redis redis-cli ping
  # 应返回: PONG
  ```
  
- [ ] **爬虫机器人已启动**
  ```bash
  docker logs modastudio-news-crawler | head -20
  ```
  
- [ ] **调度器已启动**
  ```bash
  docker logs modastudio-scheduler | head -20
  ```
  
- [ ] **数据库中有新闻**
  ```bash
  docker exec modastudio-db mysql -u magicai -psecret magicai -e "SELECT COUNT(*) FROM news;"
  ```

---

## 🎯 三个自动运行的机器人

### 1. 📰 **News Crawler** - 新闻爬虫机器人
```
启动方式: docker-compose up -d news-crawler
运行频率: 每 30 分钟自动运行
功能:
  ✓ 从 10+ 数据源爬取新闻
  ✓ AI 自动摘要
  ✓ 自动分类
  ✓ 关键词提取
  ✓ 信心度评分
日志查看: docker logs -f modastudio-news-crawler
```

### 2. ⏱️ **Scheduler** - 计划调度器
```
启动方式: docker-compose up -d scheduler
运行频率: 24/7 持续运行
计划任务:
  ✓ 每小时: 标准新闻爬取
  ✓ 每天 02:00: 深度新闻爬取
  ✓ 每天 03:00: 数据清理
  ✓ 每周一 04:00: 生成周报告
日志查看: docker logs -f modastudio-scheduler
```

### 3. ⚙️ **Queue Worker** - 队列处理器
```
启动方式: docker-compose up -d queue-worker
运行频率: 24/7 处理异步任务
功能:
  ✓ 处理爬虫异步任务
  ✓ 处理 AI 分析任务
  ✓ 自动重试 (最多 3 次)
  ✓ 故障恢复
日志查看: docker logs -f modastudio-queue-worker
```

---

## 📊 实时监控仪表板

### 启动监控面板（自动每 30 秒刷新）
```bash
# Linux/Mac
bash monitor-bots.sh

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File monitor-bots.sh
```

监控面板显示：
- ✅ 所有服务运行状态
- 📊 CPU/内存占用率
- 📰 新闻数据统计
- 🔄 最近爬虫执行情况
- 📝 实时日志输出

---

## 🔍 检查爬虫是否真的在工作

### 方法 1: 查看日志
```bash
# 持续显示爬虫日志
docker logs -f modastudio-news-crawler

# 示例输出:
# [2026-01-09 10:30:00] Crawling HackerNews...
# [2026-01-09 10:30:15] Found 30 articles
# [2026-01-09 10:30:45] Processed 28 articles
# [2026-01-09 10:31:00] Crawling 36 Krypton...
# ...
```

### 方法 2: 检查数据库
```bash
# 进入数据库容器
docker exec -it modastudio-db bash

# 登录 MySQL
mysql -u magicai -psecret magicai

# 查看新闻数量（应该持续增加）
SELECT COUNT(*) as total_news, MAX(created_at) as latest FROM news;

# 查看具体新闻
SELECT id, title, source, created_at FROM news ORDER BY created_at DESC LIMIT 5;

# 查看爬虫执行历史
SELECT executed_at, status, articles_found, articles_saved FROM news_crawler_logs ORDER BY executed_at DESC LIMIT 10;

# 退出数据库
exit;

# 退出容器
exit;
```

### 方法 3: 查看 API 响应
```bash
# 获取最新新闻 (无需认证)
curl http://localhost:8000/api/news

# 搜索关键词
curl "http://localhost:8000/api/news/search?q=AI"

# 获取趋势新闻
curl http://localhost:8000/api/news/trending

# 按分类查询
curl "http://localhost:8000/api/news?category=AI"
```

### 方法 4: 查看容器资源占用
```bash
# 实时查看爬虫机器人的 CPU/内存
docker stats modastudio-news-crawler

# 示例输出:
# CONTAINER            CPU %    MEM USAGE / LIMIT
# modastudio-news-... 5.2%     256MiB / 2GiB
```

---

## 🛠️ 常见操作

### 手动触发爬虫（不等待 30 分钟）
```bash
docker exec modastudio-web php artisan news:crawl
```

### 查看所有计划任务
```bash
docker exec modastudio-web php artisan schedule:list
```

### 手动运行特定爬虫任务
```bash
# 爬取指定源
docker exec modastudio-web php artisan news:crawl --source=hackernews

# 深度爬取（耗时较长）
docker exec modastudio-web php artisan news:crawl --deep
```

### 查看失败的任务
```bash
docker exec modastudio-db mysql -u magicai -psecret magicai -e \
  "SELECT * FROM failed_jobs LIMIT 5;"
```

### 重试失败的任务
```bash
docker exec modastudio-web php artisan queue:retry all
```

### 清理过期数据
```bash
# 删除 30 天前的新闻
docker exec modastudio-web php artisan news:cleanup --days=30
```

---

## 🚨 常见问题排查

### 问题 1: 爬虫没有任何输出

**症状**: `docker logs modastudio-news-crawler` 显示为空

**解决方案**:
```bash
# 1. 检查容器是否在运行
docker ps | grep news-crawler

# 2. 如果未运行，查看启动错误
docker logs modastudio-news-crawler

# 3. 重启容器
docker restart modastudio-news-crawler

# 4. 等待 30 秒后再查看日志
sleep 30
docker logs -f modastudio-news-crawler
```

### 问题 2: 数据库连接失败

**症状**: 日志显示 "Connection refused" 或 "Access denied"

**解决方案**:
```bash
# 1. 检查 MySQL 是否运行
docker ps | grep db

# 2. 测试连接
docker exec modastudio-db mysql -u magicai -psecret -e "SELECT 1"

# 3. 如果失败，查看 MySQL 日志
docker logs modastudio-db

# 4. 重启 MySQL
docker restart modastudio-db

# 5. 等待数据库启动完成（可能需要 10-15 秒）
sleep 15
docker exec modastudio-web php artisan migrate
```

### 问题 3: Redis 连接失败

**症状**: 日志显示 "Redis connection refused"

**解决方案**:
```bash
# 1. 检查 Redis 是否运行
docker ps | grep redis

# 2. 测试连接
docker exec modastudio-redis redis-cli ping

# 3. 如果返回 PONG，连接正常
# 如果无响应，重启 Redis
docker restart modastudio-redis
```

### 问题 4: 新闻源未配置

**症状**: 爬虫运行但没有发现新闻

**解决方案**:
```bash
# 1. 检查新闻源是否已启用
docker exec modastudio-db mysql -u magicai -psecret magicai -e \
  "SELECT name, status FROM news_sources;"

# 2. 如果为空，运行数据库 seeder
docker exec modastudio-web php artisan db:seed --class=NewsSourceSeeder

# 3. 验证新闻源已添加
docker exec modastudio-db mysql -u magicai -psecret magicai -e \
  "SELECT COUNT(*) FROM news_sources;"
```

### 问题 5: 爬虫很慢或超时

**症状**: 爬虫运行超过 10 分钟

**解决方案**:
```bash
# 1. 检查资源占用
docker stats modastudio-news-crawler

# 2. 如果 CPU/内存很高，增加资源限制
# 编辑 docker-compose.yml，在 news-crawler 服务中添加:
# deploy:
#   resources:
#     limits:
#       cpus: '1'
#       memory: 1G

# 3. 减少并发爬取数量
# 编辑 .env:
# CRAWLER_PARALLEL_JOBS=2

# 4. 重启容器
docker-compose restart news-crawler
```

---

## 📈 性能优化建议

### 1. 调整爬虫频率
编辑 `server/app/Console/Kernel.php`:
```php
// 从每 30 分钟改为每小时
$schedule->command('news:crawl')
    ->hourly()  // 改这里
    ->withoutOverlapping();
```

### 2. 并行爬取多个源
编辑 `docker-compose.yml`，复制 news-crawler 服务多次:
```yaml
news-crawler-1:
  # ...
  environment:
    CRAWLER_SOURCE: hackernews

news-crawler-2:
  # ...
  environment:
    CRAWLER_SOURCE: medium
```

### 3. 增加 Redis 缓存
编辑 `docker-compose.yml`:
```yaml
redis:
  image: redis:7
  command: redis-server --maxmemory 2gb --maxmemory-policy allkeys-lru
  ports:
    - "6379:6379"
```

### 4. 优化数据库
```bash
# 在 MySQL 中创建索引加速查询
docker exec modastudio-db mysql -u magicai -psecret magicai -e \
  "CREATE INDEX idx_news_created_at ON news(created_at DESC);"
```

---

## 🎛️ 完整命令参考

| 任务 | 命令 |
|------|------|
| **启动所有机器人** | `docker-compose up -d` |
| **停止所有机器人** | `docker-compose down` |
| **查看所有容器状态** | `docker-compose ps` |
| **实时查看爬虫日志** | `docker logs -f modastudio-news-crawler` |
| **手动触发爬虫** | `docker exec modastudio-web php artisan news:crawl` |
| **查看计划任务** | `docker exec modastudio-web php artisan schedule:list` |
| **查看数据库新闻** | `docker exec modastudio-db mysql -u magicai -psecret magicai -e "SELECT COUNT(*) FROM news;"` |
| **查看容器资源** | `docker stats modastudio-news-crawler` |
| **重启爬虫机器人** | `docker restart modastudio-news-crawler` |
| **查看爬虫执行历史** | `docker exec modastudio-db mysql -u magicai -psecret magicai -e "SELECT * FROM news_crawler_logs ORDER BY executed_at DESC LIMIT 10;"` |
| **进入数据库** | `docker exec -it modastudio-db bash` |
| **打开监控仪表板** | `bash monitor-bots.sh` |
| **验证所有机器人** | `bash verify-bots.sh` |

---

## 📝 日志文件位置

所有日志都存储在 Docker 容器中：

```
📊 爬虫日志: docker logs modastudio-news-crawler
⏱️  调度器日志: docker logs modastudio-scheduler
⚙️  队列日志: docker logs modastudio-queue-worker
🗄️  数据库日志: docker logs modastudio-db
🐍 Python 后端日志: docker logs modastudio-python-backend

# 查看完整历史日志
docker logs --tail 1000 modastudio-news-crawler
```

---

## 🔄 自动化工作流程

```
每 30 分钟 (automatic)
  ↓
News Crawler 启动
  ├─ 读取 10+ 新闻源配置
  ├─ 并行爬取 (RSS, API, 网页)
  ├─ AI 分析 (摘要、分类、关键词)
  ├─ 数据库存储
  └─ 记录爬虫日志
  ↓
数据已保存
  ├─ Web UI 显示最新新闻
  ├─ API 端点返回 JSON
  ├─ 搜索功能可用
  └─ 推荐算法工作
  ↓
每小时、每天自动执行各种计划任务
  ├─ 每天 02:00 深度爬取
  ├─ 每天 03:00 数据清理
  ├─ 每周一 04:00 生成报告
  └─ ...
```

---

## ✨ 最终成果

✅ **完全自动化**：启动一次，永远运行
✅ **24/7 运行**：无需人工干预
✅ **智能爬虫**：自动分类、摘要、关键词提取
✅ **多数据源**：10+ 预配置新闻源
✅ **可靠性高**：自动重试、故障恢复、日志记录
✅ **易于监控**：实时仪表板、数据库查询、日志查看

---

## 🎉 总结

```bash
# 就这样三步！

# 1. 进入项目目录
cd "MagicAI v9.9"

# 2. 启动所有自动机器人
docker-compose up -d

# 3. 验证运行
docker-compose ps

# 🤖 现在所有爬虫机器人会自动 24/7 运行！
```

**现在 moda.STUDIO 已成为一个完全自动化的 AI 新闻聚合平台！** 🚀
