# moda.STUDIO 后端智能客服服务

这是 moda.STUDIO 的独立后端微服务，专门用于处�?Vertex AI 的智能客服功能�?
## 快速开�?
### 本地开�?
```bash
# 1. 进入目录
cd backend-service

# 2. 创建虚拟环境
python3 -m venv venv
source venv/bin/activate  # �?Windows: venv\Scripts\activate

# 3. 安装依赖
pip install -r requirements.txt

# 4. 创建 .env 文件
cp .env.example .env

# 5. 运行应用
python app.py
```

应用将在 `http://localhost:8080` 启动�?
### 使用 Docker

```bash
# 构建镜像
docker build -t moda.STUDIO-backend .

# 运行容器
docker run -p 8080:8080 \
  -e GCP_PROJECT_ID=gen-lang-client-0654563230 \
  -e GCP_REGION=us-central1 \
  moda.STUDIO-backend
```

### �?Google Cloud Run 部署

```bash
# 推送到 GCR
docker push gcr.io/gen-lang-client-0654563230/moda.STUDIO-backend

# 部署�?Cloud Run
gcloud run deploy moda.STUDIO-backend \
  --image gcr.io/gen-lang-client-0654563230/moda.STUDIO-backend \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="GCP_PROJECT_ID=gen-lang-client-0654563230,GCP_REGION=us-central1"
```

### �?GCE 虚拟机部�?
```bash
# 方法 1：使用启动脚本（推荐�?gcloud compute instance-templates create moda.STUDIO-backend-template \
  --machine-type=e2-medium \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --metadata-from-file=startup-script=backend_startup_script.sh

# 创建实例�?gcloud compute instance-groups managed create moda.STUDIO-backend-group \
  --base-instance-name=moda.STUDIO-backend \
  --template=moda.STUDIO-backend-template \
  --size=1 \
  --region=us-central1

# 方法 2：手动运行启动脚�?curl https://raw.githubusercontent.com/v3ai2026/moda.STUDIO-v9.9/main/backend-service/backend_startup_script.sh | bash
```

## API 文档

### 1. 健康检�?
```bash
GET /health
```

**响应:**
```json
{
  "status": "healthy"
}
```

### 2. 主页

```bash
GET /
```

**响应:**
```json
{
  "service": "moda.STUDIO Backend Service",
  "version": "1.0",
  "status": "running",
  "endpoints": {
    "/health": "健康检�?,
    "/api/chat": "智能客服对话",
    "/api/v1/chat": "客服对话（V1 API�?
  }
}
```

### 3. 智能客服对话

```bash
POST /api/chat
Content-Type: application/json

{
  "question": "你们的产品价格是多少�?,
  "history": []  // 可选：对话历史
}
```

**响应:**
```json
{
  "status": "success",
  "answer": "感谢您的提问！我们提供多种价格方�?..",
  "timestamp": "2026-01-03T12:00:00Z",
  "model": "gemini-pro"
}
```

### 4. 列出可用模型

```bash
GET /api/models
```

**响应:**
```json
{
  "status": "success",
  "models": [
    {
      "id": "gemini-pro",
      "name": "Gemini Pro",
      "type": "text-generation"
    },
    {
      "id": "gemini-pro-vision",
      "name": "Gemini Pro Vision",
      "type": "multimodal"
    }
  ],
  "default": "gemini-pro"
}
```

## 环境变量

| 变量 | 默认�?| 说明 |
|------|--------|------|
| `GCP_PROJECT_ID` | `gen-lang-client-0654563230` | Google Cloud 项目 ID |
| `GCP_REGION` | `us-central1` | Vertex AI 区域 |
| `MODEL_ID` | `gemini-pro` | 使用�?AI 模型 |
| `PORT` | `8080` | 监听端口 |
| `FLASK_ENV` | `production` | Flask 环境 |

## �?moda.STUDIO 主应用集�?
�?moda.STUDIO Laravel 后端中调用此服务�?
```php
// app/Services/Ai/VertexAIService.php
namespace App\Services\Ai;

use Illuminate\Support\Facades\Http;

class VertexAIService
{
    protected $backendUrl = 'http://backend-service:8080';
    
    public function chat(string $question)
    {
        $response = Http::post("{$this->backendUrl}/api/chat", [
            'question' => $question,
        ]);
        
        return $response->json('answer');
    }
}

// 在控制器中使�?public function chatWithAI(Request $request)
{
    $service = app(VertexAIService::class);
    $answer = $service->chat($request->input('question'));
    
    return response()->json(['answer' => $answer]);
}
```

## 监控和日�?
### 查看服务日志

```bash
# Systemd 日志
journalctl -u moda.STUDIO-backend -f

# Docker 日志
docker logs -f <container_id>

# Cloud Run 日志
gcloud run logs read moda.STUDIO-backend --region=us-central1 --limit=50
```

### 监控指标

�?Google Cloud Console 中查看：
- **Cloud Logging**: 应用日志
- **Cloud Monitoring**: CPU、内存、请求数等指�?- **Cloud Trace**: 请求追踪

## 故障排除

### 问题 1: Vertex AI API 未启�?
```bash
gcloud services enable aiplatform.googleapis.com --project=gen-lang-client-0654563230
```

### 问题 2: 权限不足

确保服务账号有以下权限：
- `aiplatform.user`
- `aiplatform.serviceAgent`

```bash
gcloud projects add-iam-policy-binding gen-lang-client-0654563230 \
  --member="serviceAccount:your-sa@gen-lang-client-0654563230.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

### 问题 3: 请求超时

增加 Gunicorn 超时时间�?```bash
gunicorn --timeout 300 app:app
```

## 性能优化

1. **使用连接�?*: 复用 Vertex AI 连接
2. **缓存**: 对常见问题进行缓�?3. **异步处理**: 使用 Celery 处理耗时操作
4. **负载均衡**: 使用 Google Cloud Load Balancer 分配流量

## 安全�?
- �?�?VPC 中运行（不直接暴露到互联网）
- �?使用服务账号认证（无需 API 密钥�?- �?HTTPS 加密（通过 Cloud Armor�?- �?速率限制（在 Cloud Load Balancer 层）

## 相关文档

- [Vertex AI 文档](https://cloud.google.com/vertex-ai/docs)
- [Gemini API 指南](https://ai.google.dev)
- [Google Cloud 部署指南](https://cloud.google.com/docs)
- [Flask 文档](https://flask.palletsprojects.com/)

## 许可�?
MIT License
