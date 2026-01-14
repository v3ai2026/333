# moda.STUDIO 系统架构

## 5 端点架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                    用户浏览器/客户端                          │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼────┐ ┌────▼────┐  ┌───▼────┐
   │ Web UI  │ │  API    │  │Dashboard│
   │:8000   │ │:8000    │  │:8000    │
   └────┬────┘ └────┬────┘  └───┬────┘
        │           │            │
        └───────────┼────────────┘
                    │
        ┌───────────▼───────────┐
        │  Laravel 前端端点 (2)  │
        │   http://localhost:8000 │
        │  ✅ Web UI/Dashboard   │
        │  ✅ 模板渲染           │
        │  ✅ 用户认证           │
        │  ✅ 支付处理           │
        │  ✅ 扩展管理           │
        └───────────┬───────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
   ┌────▼─────┐ ┌──▼────┐ ┌───▼────┐
   │  MySQL   │ │ Redis │ │Python  │
   │  (1)     │ │ (4)   │ │(3)    │
   └──────────┘ └───────┘ └───┬───┘
                              │
                    ┌─────────▼────────┐
                    │ Python后端:8080  │
                    │ ✅ Vertex AI    │
                    │ ✅ Gemini LLM  │
                    │ ✅ 缓存管理      │
                    │ ✅ 速率限制      │
                    └──────────────────┘
```

---

## 5 个核心端点详解

### 端点 1️⃣ : MySQL 数据库
```
配置:
- 主机: localhost:3306
- 用户: root
- 密码: (在 .env 中配置)
- 数据库: magicai

职责:
✅ 存储所有应用数据
✅ 60+ 数据表
✅ 支持 InnoDB 事务
✅ UTF-8 多语言支持

连接:
- Laravel: PDO/Eloquent ORM
- Python: 通过 Laravel API
```

**关键表:**
```
- users (用户)
- chatbots (聊天机器人)
- chatbot_data (训练数据)
- chatbot_history (对话记录)
- ai_tools (AI 工具配置)
- ai_tool_usage_logs (使用统计)
- app_settings (应用配置)
- extensions (扩展)
- subscriptions (订阅计划)
```

---

### 端点 2️⃣ : Laravel Web 服务
```
配置:
- URL: http://localhost:8000
- 框架: Laravel 10
- 服务器: PHP 8.1+
- 编译: Vite

职责:
✅ 服务 Web UI
✅ 处理 REST API
✅ 用户认证
✅ 支付集成
✅ 扩展管理
✅ 主题切换

核心功能:
- 🎨 前端编辑器
- 📊 数据仪表板
- 💬 聊天机器人构建器
- 🔐 权限管理
- 💳 计费和订阅
- 📦 扩展市场
```

**路由示例:**
```
GET  /                      # 首页
GET  /admin                 # 管理仪表板
POST /api/auth/register     # 注册
POST /api/auth/login        # 登录
GET  /api/ai-tools          # 获取 AI 工具
POST /api/ai-tools/{slug}/execute
GET  /api/chatbots
POST /api/chatbots
```

---

### 端点 3️⃣ : Python 后端服务
```
配置:
- URL: http://localhost:8080
- 框架: Flask
- 端口: 8080
- 依赖: Vertex AI SDK

职责:
✅ 调用 Vertex AI
✅ 运行 Gemini LLM
✅ 响应缓存
✅ 速率限制
✅ 错误处理

核心功能:
- 🤖 聊天完成
- 📝 文本生成
- 🔄 缓存管理
- 🛡️ 速率限制
- 📊 使用统计
```

**API 端点:**
```
POST /api/chat
  请求: {"question": "...", "history": [...]}
  响应: {"answer": "...", "cached": false}

GET  /health
  检查服务健康状态
```

**示例请求:**
```bash
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "question": "什么是人工智能?",
    "history": []
  }'
```

---

### 端点 4️⃣ : Redis 缓存（可选）
```
配置:
- 主机: localhost:6379
- 端口: 6379
- 模式: 单机/集群

职责:
✅ 会话存储
✅ 查询缓存
✅ 任务队列
✅ 速率限制计数
✅ 实时数据

使用场景:
- 缓存 AI 响应
- 存储用户会话
- 队列后台任务
- 存储 rate limit 数据
```

**配置 (Laravel .env):**
```
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

---

### 端点 5️⃣ : 扩展和主题
```
位置:
- 扩展: /extensions/{ExtensionName}/
- 主题: /themes/{ThemeName}/

结构:
extension.json         # 扩展配置
├── System/            # PHP 代码
├── database/          # 迁移脚本
├── resources/         # 前端资源
└── config/            # 配置文件

职责:
✅ 扩展应用功能
✅ 自定义用户界面
✅ 添加新 AI 工具
✅ 集成第三方服务
```

**示例扩展:**
```
extensions/
├── AIChatPro/
│   ├── extension.json
│   ├── System/
│   │   ├── Controllers/
│   │   └── Services/
│   ├── database/
│   │   └── migration.sql
│   └── resources/
│       ├── views/
│       └── assets/
├── AiMusic/
├── AiVideo/
└── AiImage/
```

---

## 数据流

### 1. 用户注册流程
```
User Browser
    │
    ▼
[GET] /register         → Laravel 返回注册表单
    │
    ▼
[POST] /api/auth/register → Laravel 验证 → 保存到 MySQL
    │
    ▼
[响应] JWT Token        → 前端存储
```

### 2. AI 工具执行流程
```
User 执行 AI 工具
    │
    ▼
[POST] /api/ai-tools/{slug}/execute
    │
    ▼
Laravel 验证 + 记录日志
    │
    ▼
调用 Python 后端 (http://localhost:8080/api/chat)
    │
    ▼
Python → Vertex AI / Gemini
    │
    ▼
返回结果 → Laravel
    │
    ▼
保存使用日志 → MySQL
    │
    ▼
返回响应给客户端
```

### 3. 聊天机器人训练流程
```
上传训练数据
    │
    ▼
Laravel 保存到 chatbot_data 表
    │
    ▼
生成向量嵌入 (VectorService)
    │
    ▼
保存到 chatbot_data_vectors
    │
    ▼
构建完成 (Redis 缓存结果)
    │
    ▼
用户可以进行对话
```

---

## 部署架构选项

### 选项 A: Docker (推荐 ⭐)
```
┌─────────────────────────────────────┐
│      Docker Compose                 │
├─────────────────────────────────────┤
│ Container: Laravel (8000)           │
│ Container: Python (8080)            │
│ Container: MySQL (3306)             │
│ Container: Redis (6379)             │
│ Container: Nginx (80/443)           │
└─────────────────────────────────────┘
         ↓ docker-compose up
    所有服务同时启动
```

### 选项 B: 单服务器
```
┌─────────────────────────────────────┐
│    单个 Linux 服务器                 │
├─────────────────────────────────────┤
│ Systemd Service: Laravel            │
│ Systemd Service: Python             │
│ Systemd Service: MySQL              │
│ Systemd Service: Redis              │
│ Nginx: 反向代理                      │
└─────────────────────────────────────┘
```

### 选项 C: 云平台
```
┌──────────────────────────────────────┐
│  AWS / Azure / Google Cloud          │
├──────────────────────────────────────┤
│ RDS: MySQL 数据库                    │
│ ElastiCache: Redis                   │
│ App Service / Compute Engine: Laravel│
│ Cloud Run / Lambda: Python 函数      │
│ CloudFront / CDN: 静态资源           │
└──────────────────────────────────────┘
```

---

## 性能指标

| 端点 | 类型 | 延迟 | 吞吐量 | 连接数 |
|------|------|------|--------|--------|
| MySQL | DB | <10ms | 10k+ ops/s | 100-1000 |
| Laravel | Web | 100-500ms | 100 req/s | 1000+ |
| Python | API | 1-5s | 10 req/s | 100+ |
| Redis | Cache | <1ms | 100k+ ops/s | 10000+ |
| Extensions | Code | varies | varies | varies |

---

## 监控和日志

```
应用日志:
├── Laravel: storage/logs/laravel.log
├── Python: stdout/stderr
├── MySQL: /var/log/mysql/error.log
├── Redis: 内存中统计

监控点:
✅ API 响应时间
✅ 数据库连接数
✅ 内存使用率
✅ AI 工具成本
✅ 错误率
✅ 并发用户数
```

---

## 扩展性规划

```
现在 (单机)
    ▼
1000+ 用户 → 添加 Redis + CDN
    ▼
10000+ 用户 → 数据库分片 + 负载均衡
    ▼
100000+ 用户 → 微服务 + Kubernetes
```

---

## 安全架构

```
┌─────────────────┐
│  用户请求        │
└────────┬────────┘
         │
    ┌────▼─────┐
    │ Firewall │
    └────┬─────┘
         │
    ┌────▼──────────┐
    │ HTTPS/TLS 1.3 │
    └────┬──────────┘
         │
    ┌────▼──────────┐
    │ API Gateway   │
    │ (速率限制)    │
    └────┬──────────┘
         │
    ┌────▼──────────────┐
    │ 认证 (JWT Token)  │
    └────┬──────────────┘
         │
    ┌────▼───────────────┐
    │ 应用级授权          │
    │ (权限检查)          │
    └────┬───────────────┘
         │
    ┌────▼──────────┐
    │ 数据验证      │
    │ (参数清理)    │
    └────┬──────────┘
         │
    ┌────▼──────────┐
    │ 审计日志      │
    │ (所有操作)    │
    └────┬──────────┘
         │
    ┌────▼──────────┐
    │ 数据加密      │
    │ (at rest)     │
    └───────────────┘
```

---

**moda.STUDIO v9.9 - 企业级 AI SaaS 架构** 🏗️
