# Docker Compose 配置详解

## 📋 docker-compose.yml 结构

更新后的 `docker-compose.yml` 现在包含 **7 个相互协作的服务**：

```yaml
version: '3.8'

services:
  # 1️⃣ 核心基础设施 (5 个服务)
  db                    # MySQL 8.0 数据库
  redis                 # Redis 缓存/消息队列
  web                   # Laravel 主应用
  python-backend        # Gemini AI 微服务
  
  # 2️⃣ 异步处理 (1 个服务)
  queue-worker          # 处理后台任务
  
  # 3️⃣ 自动化机器人 (2 个新服务) ⭐
  news-crawler          # 📰 爬虫机器人 (每 30 分钟)
  scheduler             # ⏱️  调度器 (24/7 运行)

volumes:
  db_data               # MySQL 数据持久化

networks:
  moda-network          # 服务间通信
```

---

## 🔄 服务之间的通信流程

```
┌─────────────────────────────────────────────────────────┐
│            用户访问 Web 应用                             │
│        http://localhost:8000                            │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────────┐
        │      Nginx/Laravel Web App         │
        │    (web service, port 8000)        │
        └───────────────────────────────────┘
              ▲        │        ▲
              │        │        │
        ┌─────┴───┬────┴─┬──────┴──────┐
        │         │      │             │
        ▼         ▼      ▼             ▼
    ┌────────┐ ┌──────┐ ┌──────┐  ┌──────────┐
    │ MySQL  │ │Redis │ │Python│  │ Gemini   │
    │   DB   │ │Queue │ │Micro │  │   API    │
    └────────┘ └──────┘ └──────┘  └──────────┘
        ▲         ▲               
        │         │               
        └────┬────┴────────┬──────────────┐
             │             │              │
        ┌────▼─┐    ┌──────▼──┐    ┌─────▼──┐
        │news- │    │schedule │    │ queue- │
        │crawl │    │   er    │    │ worker │
        └──────┘    └─────────┘    └────────┘
          ⭐          ⭐              ⭐
        (30min)   (24/7 run)    (async tasks)
        爬虫机器人  调度器机器人  后台处理
```

---

## 🔧 详细服务配置说明

### 1️⃣ **db** - MySQL 数据库
```yaml
db:
  image: mysql:8.0                           # MySQL 8.0 镜像
  restart: always                            # 自动重启
  environment:
    MYSQL_ROOT_PASSWORD: secret
    MYSQL_DATABASE: magicai                  # 数据库名
    MYSQL_USER: magicai
    MYSQL_PASSWORD: secret
  volumes:
    - db_data:/var/lib/mysql                 # 数据持久化
  ports:
    - "3306:3306"                            # 暴露端口
```

**用途**: 存储所有应用数据
- users (用户)
- news (新闻内容)
- news_sources (新闻源配置)
- news_crawler_logs (爬虫执行日志)
- chatbot (聊天机器人)
- subscriptions (订阅)
- 等等...

---

### 2️⃣ **redis** - 缓存和消息队列
```yaml
redis:
  image: redis:7                             # Redis 7 镜像
  restart: always
  ports:
    - "6379:6379"                            # 暴露端口
```

**用途**:
- 缓存应用数据（加快访问速度）
- 消息队列（存储待处理任务）
- 会话存储（用户登录状态）
- 实时数据流处理

---

### 3️⃣ **web** - Laravel 主应用
```yaml
web:
  build:
    context: "./MagicAI v9.9/Magicai-Server-Files"
    dockerfile: Dockerfile
  depends_on:
    - db                                     # 依赖 MySQL
    - redis
    - python-backend
  environment:
    APP_ENV: local
    APP_DEBUG: 'true'
    DB_HOST: db                              # 连接到 db 服务
    DB_DATABASE: magicai
    DB_USERNAME: magicai
    DB_PASSWORD: secret
    BROADCAST_DRIVER: redis                  # 使用 Redis
    QUEUE_CONNECTION: redis
    VERTEX_AI_BACKEND_URL: http://python-backend:8080  # 连接到 AI 服务
  volumes:
    - "./MagicAI v9.9/Magicai-Server-Files:/var/www/html"
  ports:
    - "8000:8000"                            # 访问地址: http://localhost:8000
```

**用途**:
- Web 用户界面
- REST API 端点
- 管理后台
- 业务逻辑处理

---

### 4️⃣ **python-backend** - Gemini AI 微服务
```yaml
python-backend:
  build:
    context: "./MagicAI v9.9/backend-service"
    dockerfile: Dockerfile
  depends_on:
    - db
  environment:
    GCP_PROJECT_ID: your-gcp-project        # GCP 项目 ID
    GCP_REGION: your-region                  # GCP 地域
  ports:
    - "8080:8080"                            # 内部端口: 8080
```

**用途**:
- 调用 Google Gemini AI 模型
- 文本生成、摘要、分类
- 自然语言处理

**API 端点**: `http://python-backend:8080/api/chat`

---

### 5️⃣ **queue-worker** - 异步任务处理
```yaml
queue-worker:
  build:
    context: "./MagicAI v9.9/Magicai-Server-Files"
    dockerfile: Dockerfile
  depends_on:
    - db
    - redis
  command: php artisan queue:work --tries=3 --timeout=60
  environment:
    APP_ENV: local
    APP_DEBUG: 'true'
    DB_HOST: db
    DB_DATABASE: magicai
    DB_USERNAME: magicai
    DB_PASSWORD: secret
    QUEUE_CONNECTION: redis
  restart: always
```

**用途**:
- 处理后台任务（不阻断用户请求）
- 执行爬虫任务
- 处理 AI 分析任务
- 发送邮件通知
- 任务失败自动重试（最多 3 次）
- 单个任务超时 60 秒

---

### 6️⃣ **news-crawler** - 📰 爬虫机器人 ⭐ (新增)
```yaml
news-crawler:
  build:
    context: "./MagicAI v9.9/Magicai-Server-Files"
    dockerfile: Dockerfile
  depends_on:
    - db
    - redis
    - web
  command: sh -c "while true; do php artisan news:crawl; sleep 1800; done"
  environment:
    APP_ENV: local
    APP_DEBUG: 'false'
    DB_HOST: db
    DB_DATABASE: magicai
    DB_USERNAME: magicai
    DB_PASSWORD: secret
    QUEUE_CONNECTION: redis
    VERTEX_AI_BACKEND_URL: http://python-backend:8080
  restart: always
  logging:
    driver: "json-file"
    options:
      max-size: "10m"           # 单个日志文件最大 10MB
      max-file: "3"             # 保留最多 3 个日志文件
```

**工作流程**:
```
1. 启动爬虫循环
2. 执行 `php artisan news:crawl`
   ├─ 读取新闻源配置
   ├─ 爬取各个源的新闻
   ├─ AI 分析（摘要、分类、关键词）
   ├─ 存储到数据库
   └─ 记录爬虫日志
3. 等待 1800 秒（30 分钟）
4. 重复步骤 2-3
5. 容器崩溃时自动重启
```

**重要特性**:
- ✅ **自动重启**: `restart: always`
- ✅ **自动恢复**: 崩溃时会自动重新启动
- ✅ **日志管理**: 防止日志文件过大
- ✅ **持续运行**: 24/7 不间断工作

---

### 7️⃣ **scheduler** - ⏱️ 调度器 ⭐ (新增)
```yaml
scheduler:
  build:
    context: "./MagicAI v9.9/Magicai-Server-Files"
    dockerfile: Dockerfile
  depends_on:
    - db
    - redis
    - web
  command: php artisan schedule:work
  environment:
    APP_ENV: local
    APP_DEBUG: 'false'
    DB_HOST: db
    DB_DATABASE: magicai
    DB_USERNAME: magicai
    DB_PASSWORD: secret
    QUEUE_CONNECTION: redis
    VERTEX_AI_BACKEND_URL: http://python-backend:8080
  restart: always
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
```

**功能**: 在 Docker 中运行 PHP 的任务调度器（相当于 Linux cron）

**执行计划** (在 `server/app/Console/Kernel.php` 中定义):
```
├─ 每小时: `php artisan news:crawl` (标准爬取)
├─ 每天 02:00: `php artisan news:crawl --deep` (深度爬取)
├─ 每天 03:00: `php artisan news:cleanup` (清理过期数据)
├─ 每周一 04:00: `php artisan news:report` (生成周报告)
└─ ...
```

---

## 🌐 网络配置

```yaml
networks:
  moda-network:
    driver: bridge
```

所有服务通过 `moda-network` 桥接网络连接，允许彼此通信：
- `web` 可以访问 `db:3306` (MySQL)
- `news-crawler` 可以访问 `redis:6379` (Redis)
- `news-crawler` 可以访问 `python-backend:8080` (AI API)
- 等等...

---

## 💾 数据持久化

```yaml
volumes:
  db_data:
```

MySQL 数据存储在 `db_data` 卷中，即使容器重启也不会丢失。

**数据保存位置**:
- Linux: `/var/lib/docker/volumes/magicai_db_data/_data/`
- Windows: `%APPDATA%\Docker\volumes\magicai_db_data\_data\`

---

## 🔄 服务依赖关系

```
db (MySQL)
  ↑
  ├─ web
  ├─ queue-worker
  ├─ news-crawler
  ├─ scheduler
  └─ python-backend

redis (Redis)
  ↑
  ├─ web
  ├─ queue-worker
  ├─ news-crawler
  └─ scheduler

python-backend (Gemini API)
  ↑
  ├─ web
  ├─ queue-worker
  ├─ news-crawler
  └─ scheduler
```

**依赖说明**:
- 所有服务都依赖 MySQL 和 Redis
- 所有服务都可以访问 Python 后端 AI 服务
- `queue-worker`, `news-crawler`, `scheduler` 都在 `web` 之后启动
- 使用 `depends_on` 确保启动顺序正确

---

## 🚀 启动和停止

### 启动所有服务
```bash
docker-compose up -d
```

启动顺序（自动处理）:
1. db (MySQL)
2. redis (Redis)
3. web (Laravel)
4. python-backend (Gemini API)
5. queue-worker (异步处理)
6. news-crawler (爬虫) ⭐
7. scheduler (调度器) ⭐

### 查看所有服务状态
```bash
docker-compose ps
```

### 停止所有服务
```bash
docker-compose down
```

### 重启特定服务
```bash
docker-compose restart news-crawler
docker-compose restart scheduler
```

### 查看实时日志
```bash
docker-compose logs -f news-crawler
docker-compose logs -f scheduler
docker-compose logs -f queue-worker
```

---

## 📊 监控和调试

### 查看所有容器
```bash
docker ps -a
```

### 进入特定容器
```bash
docker exec -it modastudio-web bash
docker exec -it modastudio-db bash
docker exec -it modastudio-news-crawler bash
```

### 查看容器资源使用
```bash
docker stats

# 或只看特定容器
docker stats modastudio-news-crawler modastudio-scheduler
```

### 导出 Docker 日志
```bash
docker logs modastudio-news-crawler > crawler.log
docker logs modastudio-scheduler > scheduler.log
docker logs modastudio-queue-worker > queue-worker.log
```

---

## 🔧 常见修改

### 修改爬虫频率
编辑 `docker-compose.yml` 中的 `news-crawler` 服务：
```yaml
news-crawler:
  command: sh -c "while true; do php artisan news:crawl; sleep 3600; done"
  # 改 sleep 参数：
  # 1800 = 30 分钟
  # 3600 = 1 小时
  # 7200 = 2 小时
```

### 增加容器内存限制
编辑 `docker-compose.yml`，为需要的服务添加：
```yaml
news-crawler:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
```

### 修改数据库密码
编辑 `docker-compose.yml`：
```yaml
db:
  environment:
    MYSQL_PASSWORD: your_new_password  # 改这里
```

**注意**: 修改后需要删除旧数据重新初始化:
```bash
docker-compose down -v  # 删除所有数据
docker-compose up -d
```

### 添加环境变量
编辑 `docker-compose.yml`，为 `news-crawler` 添加：
```yaml
news-crawler:
  environment:
    CRAWLER_BATCH_SIZE: 10        # 批处理大小
    CRAWLER_TIMEOUT: 300          # 超时秒数
    AI_PROVIDER: gemini           # AI 提供商
```

---

## ✨ 总结

| 服务 | 角色 | 自动运行 |
|------|------|---------|
| db | 数据存储 | ✅ |
| redis | 缓存/队列 | ✅ |
| web | 主应用 | ✅ |
| python-backend | AI 微服务 | ✅ |
| queue-worker | 后台任务 | ✅ 24/7 |
| news-crawler | 爬虫机器人 | ✅ 每 30 分钟 |
| scheduler | 计划任务 | ✅ 24/7 |

**总共 7 个完全自动化的服务，无需人工干预！** 🎉
