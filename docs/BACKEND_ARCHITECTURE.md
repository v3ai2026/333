# 🌐 LLamaSpider 全能系统 - 后端完整架构

## 系统概览

```
┌─────────────────────────────────────────────────┐
│          🌐 Web UI 前端 (Vue3/React)             │
└──────────────┬──────────────────────────────────┘
               │
┌──────────────▼──────────────────────────────────┐
│    🚀 FastAPI 网关 (fastapi_gateway.py)         │
│  ├─ JWT 认证                                    │
│  ├─ 请求路由                                    │
│  ├─ 速率限制                                    │
│  └─ 错误处理                                    │
└──────────────┬──────────────────────────────────┘
               │
    ┌──────────┼──────────┬──────────┬──────────┐
    │          │          │          │          │
┌───▼──┐  ┌───▼──┐  ┌───▼──┐  ┌───▼──┐  ┌───▼──┐
│爬虫  │  │AI    │  │搜索  │  │分析  │  │图谱  │
│      │  │引擎  │  │引擎  │  │引擎  │  │      │
└───┬──┘  └───┬──┘  └───┬──┘  └───┬──┘  └───┬──┘
    │         │         │         │         │
    │  ChromaDB  Elasticsearch  Polars    Neo4j
    │   RAG       (ES)          DuckDB   (图数据库)
    │  (向量)     (全文)        (分析)     (关系)
    │
    └─────────────────────────────────┐
        ┌──────────────────────────────▼─────┐
        │ 📊 Celery 任务队列 + Redis          │
        │  ├─ 爬虫任务 x N                    │
        │  ├─ AI 处理任务 x N                 │
        │  └─ 定时任务 (APScheduler)          │
        └──────────────────────────────┬─────┘
             │
        ┌────▼─────────────────────────┐
        │ 💾 主数据库 (PostgreSQL)      │
        │  ├─ 爬虫数据                  │
        │  ├─ 用户信息                  │
        │  └─ 任务记录                  │
        └──────────────────────────────┘
             │
        ┌────▼──────────────────────────┐
        │ 📈 Prometheus 监控             │
        │  ├─ 性能指标                   │
        │  ├─ 健康检查                   │
        │  └─ 警报系统                   │
        └───────────────────────────────┘
```

## 核心模块详解

### 1️⃣ FastAPI 网关 (`fastapi_gateway.py`)

**职责**: API 入口、认证、路由

```bash
python scripts/fastapi_gateway.py
# 启动: http://0.0.0.0:8000
# 文档: http://0.0.0.0:8000/docs
```

**主要端点**:

- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `POST /api/crawler/submit` - 提交爬虫任务
- `GET /api/crawler/status/{task_id}` - 获取任务状态
- `POST /api/search` - 全文搜索
- `POST /api/rag/query` - RAG 知识库查询
- `POST /api/analytics` - 数据分析
- `GET /api/graph/relations/{entity}` - 查询实体关系
- `GET /api/health` - 健康检查
- `GET /api/stats` - 系统统计

### 2️⃣ ChromaDB RAG 系统 (`chromadb_rag_system.py`)

**职责**: 向量知识库、语义检索

```python
from scripts.chromadb_rag_system import rag_system

# 添加文档
rag_system.add_documents(["文档1", "文档2"])

# 查询
result = rag_system.query("搜索内容", n_results=5)
print(result["results"])
```

**功能**:

- 文档向量化（使用默认 embedding）
- 相似度检索（cosine 距离）
- 知识库管理
- 与 LLM 集成

### 3️⃣ Elasticsearch 搜索 (`elasticsearch_search.py`)

**职责**: 全文搜索、过滤、聚合

```python
from scripts.elasticsearch_search import es_search

# 索引文档
es_search.bulk_index([{"title": "...", "content": "..."}])

# 全文搜索
result = es_search.search("搜索词", limit=10)

# 带过滤搜索
result = es_search.filter_search("词", {"source": "blog"})
```

**功能**:

- 多字段全文搜索
- 模糊匹配
- 高亮显示
- 聚合分析
- 排序

### 4️⃣ Celery 任务队列 (`celery_task_queue.py`)

**职责**: 异步任务处理、定时任务

```python
from scripts.celery_task_queue import crawl_url_task, TaskMonitor

# 提交任务
task = crawl_url_task.delay("https://example.com", depth=1)

# 监控任务
status = TaskMonitor.get_task_status(task.id)
print(status)

# 启动 Worker
# celery -A scripts.celery_task_queue worker --loglevel=info
```

**功能**:

- 爬虫任务队列
- AI 处理任务
- 定时任务（每天清理、每周备份）
- 任务监控和取消

### 5️⃣ Neo4j 知识图谱 (`neo4j_graph_db.py`)

**职责**: 实体关系管理、图谱查询

```python
from scripts.neo4j_graph_db import kg

# 创建实体
kg.create_entity("Person", {"name": "Alice", "age": 30})

# 获取关系
relations = kg.get_relations("Alice")
print(relations)

# 路径搜索
paths = kg.path_search("Alice", "Bob", max_depth=5)
```

**功能**:

- 实体创建和管理
- 关系建立
- 路径查询
- 社区检测
- 知识图谱统计

### 6️⃣ 数据分析引擎 (`data_analytics_engine.py`)

**职责**: 快速数据分析、统计

```python
from scripts.data_analytics_engine import analytics

# 加载 CSV
analytics.load_csv("data.csv", "sales_data")

# 执行查询
result = analytics.query("SELECT * FROM sales_data LIMIT 10")

# 时间序列分析
ts_result = analytics.time_series_analysis("sales_data", "date", "sales", "day")

# 统计摘要
stats = analytics.statistical_summary("sales_data", "sales")
```

**功能**:

- 基于 Polars（快速） + DuckDB（高效）
- CSV 加载
- SQL 查询
- 聚合分析
- 时间序列分析
- 统计摘要
- 相关性分析
- 导出 CSV

### 7️⃣ 监控系统 (`monitoring_system.py`)

**职责**: 性能监控、健康检查、警报

```python
from scripts.monitoring_system import metrics, health_checker, alerts

# 记录指标
metrics.record_api_request("/api/search", "GET", 200)
metrics.set_active_crawls(5)

# 健康检查
health_checker.register_check("api", lambda: True)
results = health_checker.perform_checks()

# 创建警报
alerts.create_alert("warning", "CPU 过高")
```

**功能**:

- Prometheus 指标收集
- 健康检查
- 警报管理
- 性能监控

## 快速开始

### 1. 安装依赖

```bash
pip install -r requirements.txt
```

### 2. 启动所有服务

```bash
# 方式 1: Docker Compose
make docker-compose-up

# 方式 2: 手动启动各服务
# Terminal 1: FastAPI 网关
python scripts/fastapi_gateway.py

# Terminal 2: Celery Worker
celery -A scripts.celery_task_queue worker --loglevel=info

# Terminal 3: Celery Beat（定时任务）
celery -A scripts.celery_task_queue beat --loglevel=info

# Terminal 4: Ollama LLM（在 Docker 中）
docker run -d -p 11434:11434 ollama/ollama
```

### 3. 访问系统

- **API 文档**: <http://localhost:8000/docs>
- **系统状态**: <http://localhost:8000/api/health>
- **系统统计**: <http://localhost:8000/api/stats> (需登录)

## 集成示例

### 完整爬虫 + AI + 搜索 + 分析流程

```python
# 1. 提交爬虫任务
from fastapi import FastAPI
app = FastAPI()

@app.post("/crawl-and-analyze")
async def crawl_and_analyze(url: str):
    # 提交爬虫任务
    from scripts.celery_task_queue import crawl_url_task
    crawl_task = crawl_url_task.delay(url)
    
    # 等待爬虫完成...
    
    # 2. 爬虫数据 → 向量化 → RAG 知识库
    from scripts.chromadb_rag_system import rag_system
    rag_system.add_documents([crawled_content])
    
    # 3. 爬虫数据 → 全文索引 → Elasticsearch
    from scripts.elasticsearch_search import es_search
    es_search.bulk_index([{"title": "...", "content": crawled_content}])
    
    # 4. 数据分析
    from scripts.data_analytics_engine import analytics
    stats = analytics.query("SELECT COUNT(*) FROM crawled_data")
    
    # 5. 构建知识图谱
    from scripts.neo4j_graph_db import kg
    kg.create_entity("WebPage", {"url": url, "title": "..."})
    
    return {
        "crawl_task_id": crawl_task.id,
        "status": "processing",
        "rag_docs": len(rag_system.get_stats()),
        "search_index": es_search.get_stats(),
        "analytics": stats
    }
```

## 配置文件

### `.env` 示例

```bash
# 数据库
DATABASE_URL=postgresql://user:pass@localhost:5432/llamaspider
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=secret

# Redis
REDIS_URL=redis://localhost:6379/0

# Neo4j
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password

# Elasticsearch
ELASTICSEARCH_HOST=http://localhost:9200

# Ollama LLM
OLLAMA_API_URL=http://localhost:11434

# FastAPI
JWT_SECRET=your-secret-key-change-this
JWT_ALGORITHM=HS256
JWT_EXPIRE_HOURS=24
```

## 生产部署

### Docker 一键部署

```bash
docker-compose -f compose.llamaspider.yml up -d

# 查看日志
docker-compose -f compose.llamaspider.yml logs -f
```

### Kubernetes 部署

```bash
# 创建 deployment
kubectl apply -f k8s/fastapi-deployment.yaml

# 查看状态
kubectl get pods
```

## 监控仪表板

### Prometheus

```
http://localhost:9090
```

### Grafana

```
http://localhost:3000
```

### 自定义警报

```python
from scripts.monitoring_system import alerts

# 当 CPU > 80%
if cpu_usage > 80:
    alerts.create_alert("critical", "CPU 使用率过高")

# 当任务队列 > 1000
if queue_size > 1000:
    alerts.create_alert("warning", "任务队列堆积")
```

## 常见问题

**Q: ChromaDB 如何持久化?**
A: 使用 `duckdb+parquet` 后端，数据存储在 `./chroma_data`

**Q: Elasticsearch 如何处理大数据量?**
A: 使用分片和副本，支持自动扩展

**Q: Neo4j 如何处理超大图谱?**
A: 使用分布式 Neo4j 企业版

**Q: 任务队列如何保证不丢失?**
A: Redis 持久化 + 任务重试机制

## 性能指标

| 组件 | 吞吐量 | 延迟 | 存储 |
|------|--------|------|------|
| FastAPI | 10K req/s | <100ms | N/A |
| ChromaDB | 1K query/s | 10-50ms | SSD |
| Elasticsearch | 100K query/s | 1-10ms | SSD |
| Celery | 100 task/s | 100-500ms | RAM |
| Neo4j | 10K query/s | 10-100ms | SSD |
| DuckDB | 1M rows/s | <10ms | SSD |

## 下一步

- [ ] 实现前端 Vue3 界面
- [ ] 添加更多 AI 模型集成
- [ ] 实现分布式爬虫
- [ ] 支持多语言分析
- [ ] 添加 A/B 测试框架

---

**作者**: LLamaSpider Team
**版本**: 1.0.0
**更新**: 2026-01-09
