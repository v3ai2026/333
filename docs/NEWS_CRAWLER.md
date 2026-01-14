# 🚀 moda.STUDIO 智能新闻爬虫系统

完全自动化的新闻爬取、AI 处理、分类、推荐系统。

## 📊 系统架构

```
┌─────────────────────────────────────────────────────┐
│          新闻源（RSS、API、网页）                      │
├─────────────────────────────────────────────────────┤
│                   爬虫调度器                          │
│       (Laravel Scheduler + Queued Jobs)             │
├─────────────────────────────────────────────────────┤
│          NewsCrawlerService 爬虫服务                 │
│    ├─ RSS 解析    ├─ API 调用                       │
│    └─ 网页爬取    └─ 自定义爬虫                     │
├─────────────────────────────────────────────────────┤
│            AI 智能处理模块                           │
│    ├─ 摘要生成   ├─ 分类识别                        │
│    ├─ 关键词提取  └─ 置信度评分                     │
├─────────────────────────────────────────────────────┤
│            数据库存储模块                           │
│    ├─ news_sources     ├─ news                     │
│    ├─ news_crawler_logs├─ news_keywords           │
│    └─ user_news_preferences                       │
├─────────────────────────────────────────────────────┤
│            API 服务层                              │
│    ├─ 新闻查询   ├─ 源管理                         │
│    ├─ 爬取控制   └─ 个性化推荐                     │
└─────────────────────────────────────────────────────┘
```

## 🗄️ 数据库表结构

### 1. `news_sources` - 新闻源配置表
```sql
CREATE TABLE news_sources (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) UNIQUE,           -- 源名称
    type ENUM('rss','api','webpage'),   -- 源类型
    url TEXT,                           -- 源地址
    config JSON,                        -- 配置参数
    enabled BOOLEAN DEFAULT TRUE,       -- 是否启用
    priority INT DEFAULT 0,             -- 优先级
    crawl_interval INT DEFAULT 3600,    -- 爬取间隔(秒)
    last_crawled_at TIMESTAMP,          -- 最后爬取时间
    created_at, updated_at, deleted_at
);
```

### 2. `news` - 新闻内容表
```sql
CREATE TABLE news (
    id BIGINT PRIMARY KEY,
    source_id BIGINT,                   -- 来源 ID
    title VARCHAR(255),                 -- 标题
    content LONGTEXT,                   -- 内容
    summary TEXT,                       -- AI 摘要
    source_url VARCHAR(255) UNIQUE,     -- 原始链接
    category VARCHAR(50),               -- 分类
    tags JSON,                          -- 标签
    author VARCHAR(255),                -- 作者
    image_url VARCHAR(255),             -- 封面图
    published_at TIMESTAMP,             -- 发布时间
    crawled_at TIMESTAMP,               -- 爬取时间
    views INT DEFAULT 0,                -- 浏览数
    ai_confidence INT 0-100,            -- AI 置信度
    status ENUM('draft','published'),   -- 状态
    ai_notes TEXT,                      -- AI 备注
    created_at, updated_at, deleted_at,
    FULLTEXT INDEX (title, content),
    INDEX (status, category, published_at)
);
```

### 3. `news_crawler_logs` - 爬取日志
```sql
CREATE TABLE news_crawler_logs (
    id BIGINT PRIMARY KEY,
    source_id BIGINT,
    status ENUM('success','failed','partial'),
    fetched_count INT,
    processed_count INT,
    saved_count INT,
    duplicate_count INT,
    error_message TEXT,
    execution_time DECIMAL(8,3),
    details JSON,
    created_at
);
```

### 4. `news_keywords` - 关键词表
```sql
CREATE TABLE news_keywords (
    id BIGINT PRIMARY KEY,
    news_id BIGINT,
    keyword VARCHAR(255),
    frequency FLOAT 0-1,
    created_at, updated_at
);
```

### 5. `user_news_preferences` - 用户偏好
```sql
CREATE TABLE user_news_preferences (
    id BIGINT PRIMARY KEY,
    user_id BIGINT,
    interested_categories JSON,
    interested_keywords JSON,
    blocked_keywords JSON,
    preferred_sources JSON,
    ai_recommendations BOOLEAN DEFAULT TRUE,
    created_at, updated_at
);
```

## 🎯 主要特性

### ✅ 自动爬取
- **多源支持**：RSS、API、网页、自定义爬虫
- **智能调度**：按优先级和间隔自动爬取
- **失败重试**：3 次重试 + 指数退避
- **去重处理**：URL 唯一性检查

### 🧠 AI 智能处理
- **自动摘要**：生成新闻摘要
- **分类识别**：7 种分类自动识别
- **关键词提取**：AI 提取核心词汇
- **置信度评分**：质量评估 0-100 分

### 📈 数据分析
- **实时监控**：爬取状态、成功率、性能
- **内容质量**：置信度评分、手动审核
- **用户分析**：浏览数、互动数据
- **趋势分析**：热点新闻、关键词趋势

### 👤 个性化推荐
- **偏好学习**：按用户兴趣分类推荐
- **关键词过滤**：感兴趣/屏蔽关键词
- **源偏好**：选择偏好的新闻源
- **智能排序**：综合排序算法

## 🚀 快速开始

### 1. 运行迁移
```bash
php artisan migrate
php artisan db:seed --class=NewsSourceSeeder
```

### 2. 配置队列驱动
在 `.env` 配置：
```env
QUEUE_CONNECTION=redis  # 或 sync/database
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=redis123
```

### 3. 启动队列工作进程
```bash
# 开发环境
php artisan queue:work --sleep=3 --tries=3

# 生产环境（使用 Supervisor）
```

### 4. 启动定时任务调度
```bash
# 在服务器 crontab 中添加
* * * * * cd /path/to/moda.STUDIO && php artisan schedule:run >> /dev/null 2>&1
```

## 📡 API 端点

### 公开接口

#### 获取新闻列表
```bash
GET /api/news?page=1&per_page=20&sort=latest&category=技术&search=AI
```

响应：
```json
{
    "data": [
        {
            "id": 1,
            "title": "AI 新突破",
            "content": "...",
            "summary": "摘要...",
            "category": "技术",
            "tags": ["AI", "ML"],
            "views": 1250,
            "ai_confidence": 95,
            "published_at": "2026-01-09T10:30:00Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "total": 1000,
        "per_page": 20
    }
}
```

#### 获取单条新闻
```bash
GET /api/news/{id}
```

#### 获取热点新闻
```bash
GET /api/news/trending?days=7&limit=10
```

#### 获取分类
```bash
GET /api/news/categories
```

响应：
```json
{
    "categories": ["技术", "财经", "体育", "娱乐", "政治", "社会"]
}
```

#### 个性化推荐
```bash
GET /api/news/user/recommendations
# 需要认证
```

### 管理接口（需要认证）

#### 获取新闻源列表
```bash
GET /api/news/sources/list
```

#### 创建新闻源
```bash
POST /api/news/sources
Content-Type: application/json

{
    "name": "新源名称",
    "type": "rss",
    "url": "https://example.com/feed",
    "priority": 100,
    "crawl_interval": 3600
}
```

#### 立即爬取（同步）
```bash
POST /api/news/sources/{source_id}/crawl-now
```

#### 异步爬取（推荐）
```bash
POST /api/news/sources/{source_id}/crawl-async
```

#### 获取爬取日志
```bash
GET /api/news/sources/{source_id}/logs?per_page=20
```

#### 发布/存档/拒绝新闻
```bash
POST /api/news/{news_id}/publish
POST /api/news/{news_id}/archive
POST /api/news/{news_id}/reject
Content-Type: application/json

{
    "reason": "质量不符"  # reject 需要
}
```

## 🎛️ 命令行工具

### 爬取新闻
```bash
# 爬取所有启用的源
php artisan news:crawl

# 爬取指定源
php artisan news:crawl --source=1

# 强制爬取（忽略时间间隔）
php artisan news:crawl --force

# 同步执行（不使用队列）
php artisan news:crawl --sync

# 完整爬取
php artisan news:crawl --source=1 --force --sync
```

### 清理数据
```bash
# 清理 7 天前的新闻
php artisan news:cleanup --days=7

# 清理旧日志
php artisan news:cleanup --days=30 --logs-only
```

## ⏰ 自动调度

系统已配置以下自动任务（在 `app/Console/Kernel.php`）：

```php
// 每小时爬取一次
$schedule->command('news:crawl')->hourly();

// 每天 2 点执行完整爬取
$schedule->command('news:crawl --force')->dailyAt('02:00');

// 每天 3 点清理旧数据
$schedule->command('news:cleanup --days=7')->dailyAt('03:00');
```

## 🔧 配置说明

### 新闻源类型

#### RSS 源
```php
[
    'type' => 'rss',
    'url' => 'https://example.com/feed.xml',
]
```

#### API 源
```php
[
    'type' => 'api',
    'url' => 'https://api.example.com/news',
    'config' => [
        'params' => [
            'q' => 'search query',
            'apiKey' => 'YOUR_API_KEY',
        ],
        'headers' => [
            'Authorization' => 'Bearer TOKEN',
        ],
    ],
]
```

#### 网页爬取
```php
[
    'type' => 'webpage',
    'url' => 'https://example.com',
    'config' => [
        'selector' => '.news-item',
        'titleSelector' => '.title',
        'contentSelector' => '.content',
    ],
]
```

### 优先级和爬取间隔

- **priority**: 优先级（越大越优先）
- **crawl_interval**: 爬取间隔（秒）

推荐配置：
```
高优先级 (90-100):  1800秒  (30分钟)   - 重要新闻源
中优先级 (50-89):   3600秒  (1小时)    - 一般新闻源
低优先级 (0-49):    7200秒  (2小时)    - 低频更新源
```

## 📊 监控和调试

### 查看爬取日志
```bash
tail -f storage/logs/news-crawl.log
```

### 查看队列状态
```bash
# Redis 驱动
redis-cli
> KEYS "queue:*"
> LLEN "queue:default"

# 数据库驱动
php artisan queue:failed
```

### 数据库查询

获取最新新闻：
```sql
SELECT * FROM news 
WHERE status = 'published'
ORDER BY published_at DESC
LIMIT 20;
```

获取高质量新闻：
```sql
SELECT * FROM news 
WHERE status = 'published' 
AND ai_confidence >= 80
ORDER BY views DESC
LIMIT 20;
```

获取爬取统计：
```sql
SELECT source_id, 
       COUNT(*) as total_news,
       AVG(ai_confidence) as avg_confidence,
       SUM(views) as total_views
FROM news
GROUP BY source_id
ORDER BY total_views DESC;
```

## 🔐 安全建议

1. **API 密钥保护**
   - 使用环境变量存储 API 密钥
   - 定期轮换密钥

2. **访问控制**
   - 管理接口需要认证
   - 实现基于角色的访问控制 (RBAC)

3. **速率限制**
   - 对爬虫请求实施速率限制
   - 尊重网站 robots.txt

4. **数据验证**
   - 验证所有输入数据
   - 清理用户生成的内容

## 🐛 故障排查

### 新闻不更新
```bash
# 检查队列是否运行
php artisan queue:work

# 检查定时任务是否配置
grep "schedule:run" /var/spool/cron/crontabs/www-data

# 查看错误日志
tail -f storage/logs/laravel.log
```

### 内存溢出
- 增加 `php artisan queue:work --memory=256`
- 减少单次爬取的新闻数量

### API 连接失败
- 检查 URL 是否正确
- 验证 API 密钥
- 检查网络连接

## 📚 扩展阅读

- [Laravel 队列文档](https://laravel.com/docs/10.x/queues)
- [Laravel 调度文档](https://laravel.com/docs/10.x/scheduling)
- [RSS 规范](https://www.rssboard.org/)
- [API 最佳实践](https://www.postman.com/best-practices/)

---

**最后更新**: 2026-01-09  
**维护者**: moda.STUDIO 团队
