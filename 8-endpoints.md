# 🚀 moda.STUDIO - 8 个端点完整架构

## 📊 端点配置表

| # | 端点名称 | 容器名 | 端口 | 用途 | 状态检查 |
|----|---------|--------|------|------|---------|
| 1️⃣ | MySQL 主库 | `modastudio-db-primary` | 3306 | 数据存储 | `mysqladmin ping` |
| 2️⃣ | Redis 缓存 | `modastudio-cache` | 6379 | 会话/缓存 | `redis-cli ping` |
| 3️⃣ | Laravel Web | `modastudio-web` | 8000 | 主应用 | `http://localhost:8000/api/ping` |
| 4️⃣ | Python AI 后端 | `modastudio-ai` | 8080 | Gemini 集成 | `http://localhost:8080/api/chat` |
| 5️⃣ | Nginx 网关 | `modastudio-gateway` | 80/443 | 反向代理 | `curl localhost` |
| 6️⃣ | Prometheus 监控 | `modastudio-metrics` | 9090 | 性能指标 | `http://localhost:9090` |
| 7️⃣ | Grafana 仪表板 | `modastudio-dashboard` | 3000 | 数据可视化 | `http://localhost:3000` |
| 8️⃣ | Queue Worker | `modastudio-worker` | - | 后台任务 | `docker logs modastudio-worker` |

---

## 🔧 快速启动

### 启动所有 8 个端点
```bash
docker-compose -f docker-compose.full.yml up -d
```

### 查看所有端点状态
```bash
docker-compose -f docker-compose.full.yml ps
```

### 查看实时日志
```bash
docker-compose -f docker-compose.full.yml logs -f
```

### 停止所有服务
```bash
docker-compose -f docker-compose.full.yml down
```

---

## 📍 各端点详解

### 1️⃣ MySQL (端口 3306)
**角色**: 核心数据存储  
**数据库**: modastudio  
**初始化**: 自动加载 `magicai.sql`  
**健康检查**: 每 10 秒检查一次

```bash
# 连接
docker exec modastudio-db-primary mysql -u modastudio -pmodastudio123 modastudio

# 查看表列表
SHOW TABLES;
```

### 2️⃣ Redis (端口 6379)
**角色**: 会话存储、队列缓存、消息总线  
**密码**: redis123  
**持久化**: AOF 模式启用

```bash
# 连接
docker exec modastudio-cache redis-cli -a redis123

# 检查键数量
DBSIZE

# 监控实时操作
MONITOR
```

### 3️⃣ Laravel Web (端口 8000)
**角色**: RESTful API、Web UI、认证  
**框架**: Laravel 10  
**自动操作**: 
- 运行迁移 (`php artisan migrate`)
- 种子数据 (`php artisan db:seed`)

```bash
# 查看 Artisan 命令日志
docker logs modastudio-web

# 进入容器
docker exec -it modastudio-web bash

# 清除缓存
docker exec modastudio-web php artisan cache:clear
```

### 4️⃣ Python AI 后端 (端口 8080)
**角色**: Vertex AI/Gemini 集成、LLM 推理  
**框架**: Flask  
**依赖**: GCP 项目 ID

```bash
# 测试 AI 端点
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"question":"你好","history":[]}'

# 查看 Python 日志
docker logs modastudio-ai
```

### 5️⃣ Nginx 网关 (端口 80/443)
**角色**: 负载均衡、SSL 终止、请求路由  
**配置**: `nginx.conf`

```bash
# 测试网关
curl -v http://localhost

# 进入容器
docker exec -it modastudio-gateway sh

# 验证配置
docker exec modastudio-gateway nginx -t
```

### 6️⃣ Prometheus (端口 9090)
**角色**: 指标收集、性能监控  
**配置**: `monitoring/prometheus.yml`  
**存储周期**: 15 天默认

```bash
# 访问 Prometheus UI
# http://localhost:9090

# 查询指标示例
# Query: rate(http_request_duration_seconds_sum[5m])

# 查看 targets 状态
# http://localhost:9090/targets
```

### 7️⃣ Grafana (端口 3000)
**角色**: 数据可视化、仪表板、告警  
**默认用户**: admin / admin  
**数据源**: Prometheus (自动配置)

```bash
# 访问 Grafana
# http://localhost:3000

# 登录后：
# 1. 导入预配置仪表板 (monitoring/grafana/dashboards/)
# 2. 设置告警规则
# 3. 创建自定义图表
```

### 8️⃣ Queue Worker (后台)
**角色**: 异步任务处理、邮件发送、视频转码  
**框架**: Laravel Queue (Redis 驱动)  
**重试策略**: 最多 3 次

```bash
# 查看队列状态
docker logs modastudio-worker

# 进入容器
docker exec -it modastudio-worker bash

# 查看队列
docker exec modastudio-worker php artisan queue:failed

# 重试失败任务
docker exec modastudio-worker php artisan queue:retry all
```

---

## 🔌 端点间通信流

```
用户浏览器
    ↓
Nginx (80/443) ← [5️⃣ 网关]
    ↓
    ├─→ Laravel (8000) ← [3️⃣ Web]
    │   ├─→ MySQL (3306) ← [1️⃣ 数据库]
    │   ├─→ Redis (6379) ← [2️⃣ 缓存]
    │   ├─→ Python (8080) ← [4️⃣ AI]
    │   └─→ Queue Worker ← [8️⃣ 后台]
    │
    └─→ Prometheus (9090) ← [6️⃣ 监控]
        └─→ Grafana (3000) ← [7️⃣ 仪表板]
```

---

## 🧪 完整健康检查脚本

```bash
#!/bin/bash

echo "🔍 检查所有 8 个端点..."

# 1. MySQL
echo -n "1️⃣ MySQL ... "
docker exec modastudio-db-primary mysqladmin ping -h localhost >/dev/null 2>&1 && echo "✅" || echo "❌"

# 2. Redis
echo -n "2️⃣ Redis ... "
docker exec modastudio-cache redis-cli -a redis123 ping >/dev/null 2>&1 && echo "✅" || echo "❌"

# 3. Laravel
echo -n "3️⃣ Laravel ... "
curl -s http://localhost:8000/api/ping | grep -q "pong" && echo "✅" || echo "❌"

# 4. Python AI
echo -n "4️⃣ Python AI ... "
curl -s http://localhost:8080/health >/dev/null 2>&1 && echo "✅" || echo "❌"

# 5. Nginx
echo -n "5️⃣ Nginx ... "
curl -s http://localhost:80 >/dev/null 2>&1 && echo "✅" || echo "❌"

# 6. Prometheus
echo -n "6️⃣ Prometheus ... "
curl -s http://localhost:9090/-/healthy >/dev/null 2>&1 && echo "✅" || echo "❌"

# 7. Grafana
echo -n "7️⃣ Grafana ... "
curl -s http://localhost:3000/api/health >/dev/null 2>&1 && echo "✅" || echo "❌"

# 8. Queue Worker
echo -n "8️⃣ Queue Worker ... "
docker ps | grep modastudio-worker >/dev/null 2>&1 && echo "✅" || echo "❌"

echo "✨ 检查完成"
```

---

## 📈 监控仪表板配置

### Prometheus 指标示例
```promql
# 请求速率 (5分钟平均)
rate(http_request_duration_seconds_sum[5m])

# 错误率
rate(http_requests_total{status=~"5.."}[5m])

# CPU 使用率
rate(container_cpu_usage_seconds_total[5m]) * 100

# 内存使用
container_memory_usage_bytes
```

### Grafana 告警规则示例
```yaml
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
  for: 5m
  annotations:
    summary: "高错误率检测"

- alert: DatabaseDown
  expr: mysql_up == 0
  for: 1m
  annotations:
    summary: "MySQL 数据库掉线"
```

---

## 🚨 常见问题排查

### 端口冲突
```bash
# 查找占用端口的进程
lsof -i :3000  # 查找占用 3000 的进程

# 修改 compose 文件中的端口映射
```

### 数据卷权限
```bash
# 修复权限问题
docker-compose -f docker-compose.full.yml down -v
docker-compose -f docker-compose.full.yml up -d
```

### 内存不足
```bash
# 查看各容器内存使用
docker stats

# 增加 Docker 内存限制 (Docker Desktop 设置)
```

### Redis 连接失败
```bash
# 测试 Redis 连接
docker exec modastudio-cache redis-cli -a redis123 PING

# 如果失败，检查密码
```

---

## 📊 生产部署清单

- [ ] 生成新的 APP_KEY (不要使用示例值)
- [ ] 配置 GCP 凭证 (GCP_PROJECT_ID)
- [ ] 启用 SSL/TLS (修改 nginx.conf)
- [ ] 配置备份策略 (MySQL + Redis)
- [ ] 设置日志采集 (ELK Stack)
- [ ] 配置告警通知 (Slack/Email)
- [ ] 性能基准测试 (压力测试)
- [ ] 灾难恢复计划

---

## 🔐 安全加固

```bash
# 更改默认密码
# MySQL: 修改 MYSQL_PASSWORD
# Redis: 修改 redis_password
# Grafana: 修改 GF_SECURITY_ADMIN_PASSWORD

# 启用网络隔离
# networks 段已配置私有网络 (modastudio)

# 限制外部访问
# 只暴露 Nginx (80/443)
# 内部服务通过容器网络通信
```

---

## ✅ 启动命令总结

```bash
# 完整启动 (8 个端点)
docker-compose -f docker-compose.full.yml up -d

# 验证所有服务
docker-compose -f docker-compose.full.yml ps

# 查看实时日志
docker-compose -f docker-compose.full.yml logs -f

# 停止和清理
docker-compose -f docker-compose.full.yml down

# 重建镜像
docker-compose -f docker-compose.full.yml up -d --build
```

---

**最后更新**: 2026-01-09  
**维护者**: moda.STUDIO 团队
