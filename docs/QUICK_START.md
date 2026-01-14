# 🚀 LLamaSpider 全能系统 - 快速启动指南

## 📋 系统要求

- Python 3.10+
- Docker & Docker Compose
- Node.js 18+（前端开发）
- 最少 8GB RAM
- 50GB 磁盘空间

## ⚡ 超快速启动 (5 分钟)

### 方式 1: Docker 一键启动（推荐）

```bash
# 1. 进入项目目录
cd /path/to/MagicAI\ v9.9

# 2. 启动所有服务
docker-compose -f docker-compose.full-stack.yml up -d

# 3. 等待服务启动（约 30-60 秒）
docker-compose -f docker-compose.full-stack.yml logs -f

# 4. 查看服务状态
docker-compose -f docker-compose.full-stack.yml ps

# 5. 查看日志
docker-compose -f docker-compose.full-stack.yml logs -f api
```

访问地址:

- 🌐 **FastAPI 文档**: <http://localhost:8000/docs>
- 🗄️ **PostgreSQL**: localhost:5432
- 💾 **Redis**: localhost:6379
- 🔍 **Elasticsearch**: <http://localhost:9200>
- 📊 **Neo4j**: <http://localhost:7474>
- 📈 **Prometheus**: <http://localhost:9090>
- 📉 **Grafana**: <http://localhost:3000>
- 🛠️ **Adminer**: <http://localhost:8080>

---

### 方式 2: 本地开发环境启动

#### 步骤 1: 安装依赖

```bash
cd /path/to/MagicAI\ v9.9

# 安装 Python 依赖
pip install -r requirements.txt

# 安装前端依赖（如果需要）
cd frontend  # 如果有前端项目
npm install
```

#### 步骤 2: 启动基础服务（使用 Docker）

```bash
# 仅启动数据库服务
docker-compose -f docker-compose.full-stack.yml up -d \
  postgres redis elasticsearch neo4j ollama

# 等待服务就绪
sleep 30
```

#### 步骤 3: 启动 FastAPI 应用

```bash
# Terminal 1: 启动 API 服务器
python scripts/server.py api --port 8000 --reload
```

#### 步骤 4: 启动 Celery 任务队列

```bash
# Terminal 2: 启动 Celery Worker
python scripts/server.py celery

# 或分别启动
celery -A scripts.celery_task_queue worker --loglevel=info --concurrency=4
```

#### 步骤 5: 启动定时任务

```bash
# Terminal 3: 启动 Celery Beat
celery -A scripts.celery_task_queue beat --loglevel=info
```

---

## 🔧 常见命令

### Docker 相关

```bash
# 查看所有容器
docker-compose -f docker-compose.full-stack.yml ps

# 查看特定服务日志
docker-compose -f docker-compose.full-stack.yml logs api
docker-compose -f docker-compose.full-stack.yml logs celery_worker

# 进入容器 Shell
docker-compose -f docker-compose.full-stack.yml exec api bash

# 重启服务
docker-compose -f docker-compose.full-stack.yml restart api

# 停止所有服务
docker-compose -f docker-compose.full-stack.yml down

# 删除所有数据（谨慎！）
docker-compose -f docker-compose.full-stack.yml down -v
```

### 数据库管理

```bash
# 连接 PostgreSQL
psql -h localhost -U llamaspider -d llamaspider

# 连接 Redis
redis-cli -h localhost

# 连接 Neo4j（Web UI）
# http://localhost:7474

# 查看 Elasticsearch 集群状态
curl http://localhost:9200/_cluster/health
```

### API 测试

```bash
# 健康检查
curl http://localhost:8000/api/health

# 用户注册
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","email":"user@example.com","password":"pass123"}'

# 用户登录
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass123"}'

# 提交爬虫任务
curl -X POST http://localhost:8000/api/crawler/submit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"url":"https://example.com","depth":2}'

# 查询任务状态
curl http://localhost:8000/api/crawler/status/{task_id} \
  -H "Authorization: Bearer YOUR_TOKEN"

# 全文搜索
curl -X POST http://localhost:8000/api/search \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"query":"搜索词","limit":10}'

# RAG 知识库查询
curl -X POST http://localhost:8000/api/rag/query \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"question":"问题","n_results":5}'
```

---

## 📊 系统架构快速概览

```
🌐 前端 (Vue3/React)
  ↓ HTTP/WebSocket
🚀 FastAPI Gateway (8000)
  ├→ Crawler Service (爬虫)
  ├→ RAG System (知识库)
  ├→ Search Engine (搜索)
  ├→ Analytics Engine (分析)
  ├→ Graph DB (知识图谱)
  └→ Monitoring (监控)
  ↓
💾 数据层
  ├─ PostgreSQL (主数据)
  ├─ Redis (缓存)
  ├─ Elasticsearch (索引)
  ├─ Neo4j (图谱)
  ├─ DuckDB (分析)
  └─ ChromaDB (向量)
```

---

## 🔒 安全配置

### 更改默认密码

```bash
# 编辑 docker-compose.full-stack.yml
# 修改以下变量:
NEO4J_PASSWORD=your-secure-password
POSTGRES_PASSWORD=your-secure-password
GF_SECURITY_ADMIN_PASSWORD=your-secure-password
JWT_SECRET=your-long-random-secret-key
```

### 生成 JWT Secret

```bash
# Python
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Bash
openssl rand -hex 32
```

---

## 🐛 故障排除

### 问题 1: 容器无法启动

```bash
# 查看详细错误信息
docker-compose -f docker-compose.full-stack.yml logs --tail=50

# 检查端口占用
sudo lsof -i :8000  # 检查 8000 端口
sudo lsof -i :5432  # 检查 5432 端口
```

### 问题 2: 数据库连接失败

```bash
# 检查 PostgreSQL 服务
docker-compose -f docker-compose.full-stack.yml ps postgres

# 重启 PostgreSQL
docker-compose -f docker-compose.full-stack.yml restart postgres

# 查看日志
docker-compose -f docker-compose.full-stack.yml logs postgres
```

### 问题 3: 内存不足

```bash
# 检查 Docker 内存限制
docker stats

# 增加 Docker 内存分配（在 Docker Desktop 设置中）
# 或修改 docker-compose 中的内存限制:
# services:
#   api:
#     deploy:
#       resources:
#         limits:
#           memory: 2G
```

### 问题 4: Ollama 无法下载模型

```bash
# 手动拉取模型
docker-compose -f docker-compose.full-stack.yml exec ollama \
  ollama pull llama2

# 列出已有模型
docker-compose -f docker-compose.full-stack.yml exec ollama \
  ollama list
```

---

## 📈 性能优化

### 1. 增加 Celery Worker 数量

```bash
# 编辑 docker-compose.full-stack.yml
celery_worker:
  deploy:
    replicas: 4  # 增加到 4 个
```

### 2. 配置 Elasticsearch 分片

```bash
curl -X PUT http://localhost:9200/my-index \
  -H "Content-Type: application/json" \
  -d '{
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 1
    }
  }'
```

### 3. 调整 PostgreSQL 连接池

```bash
# 编辑 docker-compose.full-stack.yml 中 PostgreSQL 的环境变量
POSTGRES_INITDB_ARGS: "-c max_connections=200"
```

---

## 📚 API 文档

### 自动生成的 API 文档

- **Swagger UI**: <http://localhost:8000/docs>
- **ReDoc**: <http://localhost:8000/redoc>
- **OpenAPI JSON**: <http://localhost:8000/openapi.json>

### 主要 API 端点

| 方法 | 端点 | 说明 |
|------|------|------|
| POST | `/api/auth/register` | 用户注册 |
| POST | `/api/auth/login` | 用户登录 |
| POST | `/api/crawler/submit` | 提交爬虫任务 |
| GET | `/api/crawler/status/{id}` | 查询任务状态 |
| POST | `/api/search` | 全文搜索 |
| POST | `/api/rag/query` | RAG 查询 |
| POST | `/api/analytics` | 数据分析 |
| GET | `/api/graph/relations/{id}` | 查询关系 |
| GET | `/api/health` | 健康检查 |
| GET | `/api/stats` | 系统统计 |

---

## 🚀 部署到生产环境

### AWS ECS 部署

```bash
# 构建镜像
docker build -t llamaspider:latest .

# 推送到 ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com

docker tag llamaspider:latest \
  123456789.dkr.ecr.us-east-1.amazonaws.com/llamaspider:latest

docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/llamaspider:latest
```

### Kubernetes 部署

```bash
# 应用配置
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# 查看状态
kubectl get pods -n llamaspider
kubectl logs -n llamaspider deployment/api
```

---

## 📞 获取帮助

- 📖 **文档**: [BACKEND_ARCHITECTURE.md](BACKEND_ARCHITECTURE.md)
- 🐛 **Issues**: GitHub Issues
- 💬 **讨论**: GitHub Discussions

---

**祝你使用愉快！🎉**
