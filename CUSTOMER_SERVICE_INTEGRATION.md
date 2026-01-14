# moda.STUDIO Vertex AI 客服集成指南

## 架构概览

```
用户 �?moda.STUDIO 前端 �?Laravel 后端 �?Vertex AI 后端服务 �?Google Vertex AI
                       �?                    数据库存�?```

## 部署步骤

### 1. 部署后端微服�?
选择以下方式之一�?
#### 方式 A: Google Cloud Run（最简单）

```bash
cd backend-service

# 构建并推�?Docker 镜像
gcloud builds submit --tag gcr.io/gen-lang-client-0654563230/moda.STUDIO-backend

# 部署�?Cloud Run
gcloud run deploy moda.STUDIO-backend \
  --image gcr.io/gen-lang-client-0654563230/moda.STUDIO-backend \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --timeout 3600 \
  --set-env-vars="GCP_PROJECT_ID=gen-lang-client-0654563230,GCP_REGION=us-central1,MODEL_ID=gemini-pro"
```

#### 方式 B: Google Compute Engine（更复杂但更便宜�?
```bash
# 创建实例模板
gcloud compute instance-templates create moda.STUDIO-backend-template \
  --machine-type=e2-medium \
  --region=us-central1 \
  --network=app-vpc-network \
  --subnet=app-subnet \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --metadata-from-file=startup-script=backend-service/backend_startup_script.sh

# 创建实例�?gcloud compute instance-groups managed create moda.STUDIO-backend-group \
  --base-instance-name=moda.STUDIO-backend \
  --template=moda.STUDIO-backend-template \
  --size=1 \
  --region=us-central1
```

### 2. 配置 Laravel 应用

#### 步骤 1: 更新 .env 文件

```bash
# .env
VERTEX_AI_BACKEND_URL=http://backend-service:8080  # 内部 VPC URL
# 或者如果使�?Cloud Run:
VERTEX_AI_BACKEND_URL=https://moda.STUDIO-backend-xxxxx.run.app
```

#### 步骤 2: 创建配置文件

创建 `config/services.php` 或添加到现有文件�?
```php
'vertex_ai' => [
    'backend_url' => env('VERTEX_AI_BACKEND_URL', 'http://localhost:8080'),
],
```

#### 步骤 3: 更新路由

编辑 `routes/api.php`，添加：

```php
use App\Http\Controllers\Api\CustomerServiceController;

Route::prefix('customer-service')->middleware('throttle:60,1')->group(function () {
    Route::post('/chat', [CustomerServiceController::class, 'chat']);
    Route::get('/health', [CustomerServiceController::class, 'health']);
    Route::get('/models', [CustomerServiceController::class, 'models']);
});
```

### 3. 在前端调�?API

#### JavaScript/Vue 示例

```javascript
// 发送问题到客服
async function askCustomerService(question) {
  try {
    const response = await fetch('/api/customer-service/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        question: question,
        conversation_id: localStorage.getItem('conversation_id')
      })
    });

    const data = await response.json();
    
    if (data.status === 'success') {
      console.log('AI 回复:', data.data.answer);
      return data.data.answer;
    } else {
      console.error('错误:', data.message);
    }
  } catch (error) {
    console.error('请求失败:', error);
  }
}

// 使用示例
document.getElementById('send-btn').addEventListener('click', async () => {
  const question = document.getElementById('question-input').value;
  const answer = await askCustomerService(question);
  document.getElementById('answer-display').textContent = answer;
});
```

### 4. 配置网络和权�?
#### 确保 Vertex AI API 已启�?
```bash
gcloud services enable aiplatform.googleapis.com --project=gen-lang-client-0654563230
```

#### 授予服务账号权限

```bash
# 获取服务账号邮箱
SERVICE_ACCOUNT=$(gcloud iam service-accounts list --filter="displayName:Compute Engine default service account" --format="value(email)")

# 授予 Vertex AI 用户权限
gcloud projects add-iam-policy-binding gen-lang-client-0654563230 \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/aiplatform.user"
```

### 5. 测试部署

```bash
# 测试后端健康状�?curl https://moda.STUDIO-backend-xxxxx.run.app/health

# 测试对话 API
curl -X POST https://moda.STUDIO-backend-xxxxx.run.app/api/chat \
  -H "Content-Type: application/json" \
  -d '{"question": "你好，请介绍一下你的功�?}'

# �?Laravel 中测�?php artisan tinker
> app(App\Services\Ai\VertexAICustomerService::class)->chat('你好')
```

## 故障排除

### 问题 1: 连接超时

**症状:** `cURL error 7: Failed to connect`

**解决:**
- 检查后端服务是否运�?- 检查防火墙规则
- 检�?VPC 和子网配�?
```bash
# 检�?Cloud Run 服务状�?gcloud run services list --region=us-central1

# 检�?GCE 实例状�?gcloud compute instances list --zone=us-central1-a
```

### 问题 2: 权限拒绝

**症状:** `401 Unauthorized` �?`403 Forbidden`

**解决:**
```bash
# 确保 Vertex AI API 已启�?gcloud services list --enabled | grep aiplatform

# 重新授予权限
gcloud projects add-iam-policy-binding gen-lang-client-0654563230 \
  --member="serviceAccount:default@gen-lang-client-0654563230.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

### 问题 3: 模型不可�?
**症状:** `Model not found` �?`Invalid model ID`

**解决:**
```bash
# 列出可用模型
gcloud ai models list --region=us-central1

# 检查环境变�?echo $MODEL_ID
```

## 监控和日�?
### 查看后端服务日志

#### Cloud Run
```bash
gcloud run logs read moda.STUDIO-backend --region=us-central1 --limit=50 --follow
```

#### GCE
```bash
# SSH 进入实例
gcloud compute ssh moda.STUDIO-backend-xxxxx --zone=us-central1-a

# 查看服务日志
journalctl -u moda.STUDIO-backend -f

# 查看应用日志
tail -f /var/log/moda.STUDIO-backend.log
```

### �?Cloud Logging 中搜�?
```bash
# 搜索错误日志
gcloud logging read 'resource.type=cloud_run_revision AND resource.service_name=moda.STUDIO-backend AND severity=ERROR' --limit=50

# 搜索特定请求
gcloud logging read 'textPayload=~"question"' --limit=20
```

## 成本优化

1. **使用 Cloud Run**（按需付费�?   - 便宜，自动扩�?   - 推荐用于低到中等流量

2. **使用 GCE �?Auto Scaling**
   - 更便宜（如果 24/7 运行�?   - 需要手动配置扩�?
3. **缓存常见问题**
   - 减少 Vertex AI API 调用
   - 降低费用

4. **使用 Firestore / Redis 缓存**
   ```php
   // �?VertexAICustomerService �?   $cached = Cache::get("ai_question_{$question}");
   if ($cached) return $cached;
   
   $answer = $this->fetchFromVertexAI($question);
   Cache::put("ai_question_{$question}", $answer, now()->addHours(24));
   return $answer;
   ```

## 安全性建�?
1. �?使用 VPC 隔离后端服务
2. �?启用 Cloud Armor 防止 DDoS
3. �?使用 IAM 服务账号而非 API 密钥
4. �?启用 Cloud Audit Logs
5. �?设置 API 速率限制

```php
// 在路由中添加速率限制
Route::middleware('throttle:20,1')->group(function () {
    Route::post('/api/customer-service/chat', [CustomerServiceController::class, 'chat']);
});
```

## 相关链接

- [Vertex AI 文档](https://cloud.google.com/vertex-ai/docs)
- [Gemini API](https://ai.google.dev)
- [Cloud Run 指南](https://cloud.google.com/run/docs)
- [GCE 指南](https://cloud.google.com/compute/docs)

---

需要帮助？查看�?- `backend-service/README.md` - 后端服务文档
- `.github/DEPLOY.md` - 完整部署指南

