# moda.STUDIO AI 工具集成指南

## 功能概述

moda.STUDIO 现已集成完整的 AI 工具管理系统，包含：

- **36+ AI 工具** 覆盖 9 个分类
- **使用统计和成本追踪**
- **多提供商支持**（OpenAI、Anthropic、Azure、Gemini、FAL AI 等）
- **RESTful API** 用于集成
- **工具模板系统** 用于快速开发

## AI 工具分类

### 📝 内容生成工具 (Content)
- AI 文章写手
- AI 博客生成器
- AI 产品描述
- AI 社交媒体文案

### 🖼️ 图像处理工具 (Image)
- AI 图像生成
- AI 图像编辑
- AI 背景移除
- AI 超分辨率

### 🎥 视频工具 (Video)
- AI 视频生成
- AI 文字转视频
- AI 字幕生成
- AI 短视频编辑

### 🎵 音频工具 (Audio)
- AI 文字转语音
- AI 语音克隆
- AI 音乐生成
- AI 背景音乐库

### 💬 聊天和对话 (Chatbot)
- AI 聊天机器人
- AI 客服助手
- AI 知识库搜索
- AI 对话分析

### 📢 营销工具 (Marketing)
- AI 营销文案
- AI 邮件模板
- AI 广告创意
- AI SEO 优化

### 💻 开发工具 (Developer)
- AI 代码生成
- AI 代码文档
- AI Bug 分析
- AI 代码审查

### 📊 数据分析 (Analytics)
- AI 数据分析
- AI 预测分析
- AI 数据可视化
- AI 报告生成

### 🎨 设计工具 (Design)
- AI 设计生成
- AI 配色方案
- AI Logo 生成
- AI 排版优化

## 数据库架构

### 表结构

#### `ai_tools` - AI 工具表
```sql
- id: 主键
- name: 工具名称
- slug: URL 友好的标识符
- category: 分类（content, image, video 等）
- description: 工具描述
- icon: Font Awesome 图标
- status: 状态（enabled, disabled, beta）
- config: JSON 配置
- parameters: JSON 参数定义
- usage_count: 使用次数
- api_endpoint: API 端点
- provider: AI 提供商
- order: 排序
```

#### `ai_tool_usage_logs` - 使用日志表
```sql
- id: 主键
- user_id: 用户 ID
- ai_tool_id: 工具 ID
- input: JSON 输入数据
- output: JSON 输出数据
- tokens_used: 消耗 token 数
- cost: 成本
- status: 执行状态
- error_message: 错误信息
- execution_time_ms: 执行时间（毫秒）
```

#### `ai_tool_templates` - 工具模板表
```sql
- id: 主键
- ai_tool_id: 工具 ID
- name: 模板名称
- description: 模板描述
- default_parameters: 默认参数
- examples: 使用示例
- usage_count: 使用次数
- status: 模板状态
- order: 排序
```

## API 端点

### 1. 获取所有 AI 工具
```
GET /api/ai-tools
```
**响应：**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "AI 文章写手",
      "slug": "ai-article-writer",
      "category": "content",
      "description": "生成高质量的文章内容",
      "icon": "fa-pen",
      "status": "enabled",
      "usage_count": 150
    }
  ],
  "total": 36
}
```

### 2. 按分类获取工具
```
GET /api/ai-tools/category/{category}
```
**示例：**
```
GET /api/ai-tools/category/content
```

### 3. 获取工具详情
```
GET /api/ai-tools/{slug}
```
**示例：**
```
GET /api/ai-tools/ai-article-writer
```

### 4. 获取工具模板
```
GET /api/ai-tools/{slug}/templates
```
**响应：**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "新闻文章模板",
      "description": "用于生成新闻风格的文章",
      "default_parameters": {
        "tone": "professional",
        "length": "long"
      }
    }
  ],
  "total": 5
}
```

### 5. 执行 AI 工具
```
POST /api/ai-tools/{slug}/execute
```
**请求体：**
```json
{
  "parameters": {
    "topic": "人工智能的未来",
    "length": "long",
    "style": "professional"
  },
  "provider": "openai"
}
```
**响应：**
```json
{
  "success": true,
  "data": {
    "success": true,
    "data": "生成的内容...",
    "tokens_used": 250,
    "cost": 0.005,
    "execution_time_ms": 3200
  }
}
```

### 6. 获取工具统计
```
GET /api/ai-tools/{slug}/stats
```
**响应：**
```json
{
  "success": true,
  "data": {
    "total_uses": 150,
    "total_tokens": 15000,
    "total_cost": 0.30,
    "success_count": 148,
    "failed_count": 2,
    "average_execution_time": 3150
  }
}
```

## 使用示例

### PHP/Laravel

```php
use App\Services\Ai\AiToolService;

$aiToolService = app(AiToolService::class);

// 获取所有工具
$tools = $aiToolService->getAllEnabledTools();

// 获取特定工具
$tool = $aiToolService->getTool('ai-article-writer');

// 执行工具
$result = $aiToolService->executeTool('ai-article-writer', [
    'topic' => '人工智能',
    'length' => 'long'
]);

// 获取统计
$stats = $aiToolService->getToolStats('ai-article-writer', auth()->id());
```

### JavaScript/Frontend

```javascript
// 获取所有工具
fetch('/api/ai-tools')
  .then(res => res.json())
  .then(data => console.log(data.data));

// 获取工具详情
fetch('/api/ai-tools/ai-article-writer')
  .then(res => res.json())
  .then(data => console.log(data.data));

// 执行工具
fetch('/api/ai-tools/ai-article-writer/execute', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    parameters: {
      topic: '人工智能的未来',
      length: 'long'
    },
    provider: 'openai'
  })
})
.then(res => res.json())
.then(data => console.log(data.data));
```

## 集成步骤

### 1. 运行迁移
```bash
cd server
php artisan migrate
```

### 2. 运行 Seeder
```bash
php artisan db:seed --class=AiToolsSeeder
```

### 3. 验证数据
```bash
php artisan tinker
>>> App\Models\AiTool::count()
=> 36
```

### 4. 前端集成
在前端添加 AI 工具选择器和执行界面。

## 扩展工具

### 添加新工具

```php
// 在 AiToolsSeeder 中添加
[
    'category' => 'content',
    'name' => '新 AI 工具',
    'slug' => 'new-ai-tool',
    'description' => '工具描述',
    'icon' => 'fa-icon',
    'status' => 'enabled'
],
```

### 实现自定义提供商

```php
// 在 AiToolService 中添加
private function callCustomProvider(AiTool $tool, array $parameters): array
{
    // 实现自定义逻辑
    return [
        'success' => true,
        'data' => $result,
        'tokens_used' => 0,
        'cost' => 0,
        'execution_time_ms' => 1000,
    ];
}
```

## 成本追踪

系统自动追踪每个工具的使用情况和成本：

```php
// 获取用户的总成本
$totalCost = $user->aiToolUsageLogs()
    ->sum('cost');

// 获取每个工具的成本
$toolCosts = \App\Models\AiToolUsageLog::select('ai_tool_id')
    ->selectRaw('SUM(cost) as total_cost')
    ->groupBy('ai_tool_id')
    ->get();
```

## 安全考虑

- 所有 API 端点都需要身份验证（`auth:api` 中间件）
- 使用日志记录所有工具执行
- 支持成本限制和速率限制
- 参数验证和清理

## 性能优化

- 使用索引加快查询
- 缓存常用工具列表
- 异步执行长时间操作
- 批量处理使用日志

## 下一步

1. 实现各提供商的具体调用逻辑
2. 添加前端 UI 组件
3. 配置成本限制
4. 设置监控和告警
5. 实现工具配额管理
