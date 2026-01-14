# MagicAI v9.9 - 完整 API 文档

## 📋 API 总览

MagicAI 是一个全栈 AI 平台，包含 **50+ API 端点**，分为以下主要模块：

---

## 🔐 认证模块 (Auth)

### 公开端点

| 方法 | 路由 | 功能 |
|------|------|------|
| `POST` | `/api/auth/register` | 用户注册 |
| `POST` | `/api/auth/forgot-password` | 发送密码重置邮件 |
| `GET` | `/api/auth/email/verify` | 邮箱验证确认 |
| `POST` | `/api/auth/email/verify/resend` | 重新发送验证邮件 (限流: 6/1min) |
| `GET` | `/api/auth/social-login` | 获取支持的社交登录方式 |
| `POST` | `/api/auth/google-login` | Google 登录 |
| `POST` | `/api/auth/apple-login` | Apple 登录 |
| `GET` | `/api/auth/logo` | 获取应用 Logo |

### 需认证端点

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/user` | 获取当前用户信息 |
| `POST` | `/api/auth/logout` | 用户登出 |
| `GET` | `/api/auth/profile` | 获取用户资料 |
| `PATCH` | `/api/auth/profile` | 更新用户资料 |
| `DELETE` | `/api/auth/profile` | 删除用户账号 |

---

## ⚙️ 应用配置 (App)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/app/email-confirmation-setting` | 获取邮箱确认设置 |
| `GET` | `/api/app/get-setting` | 获取所有应用设置 |
| `GET` | `/api/app/usage-data` | 获取用户使用数据和套餐详情 |
| `GET` | `/api/app/currency/{id?}` | 获取货币信息 |

---

## 🔍 通用搜索 (General)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/general/recent-documents` | 获取最近文档 |
| `GET` | `/api/general/favorite-openai` | 获取收藏的 AI 工具 |
| `POST` | `/api/general/search` | 搜索功能 |

---

## 💬 AI 聊天 (AIChat)

### 流测试

| 方法 | 路由 | 功能 |
|------|------|------|
| `POST` | `/api/aichat/stream-test` | 测试流输出 |

### 聊天标题

| 方法 | 路由 | 功能 |
|------|------|------|
| `POST` | `/api/aichat/change-chat-title` | 更改聊天标题 |

### 聊天模板

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/aichat/chat-templates/{id?}` | 获取聊天模板 |
| `PATCH` | `/api/aichat/chat-templates` | 创建/更新聊天模板 |
| `DELETE` | `/api/aichat/chat-templates/{id}` | 删除聊天模板 |

### 聊天信息

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/aichat/chat/{conver_id}` | 获取对话详情 |
| `GET` | `/api/aichat/chat/{conver_id}/messages` | 获取对话消息 |
| `GET` | `/api/aichat/chat/{conver_id}/messages/{id}` | 获取特定消息 |
| `GET/POST` | `/api/aichat/chat-send` | 发送聊天消息 |
| `POST` | `/api/aichat/new-chat` | 开始新聊天 |

### 聊天历史

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/aichat/history/{cat_slug}` | 获取对话历史 |
| `DELETE` | `/api/aichat/history` | 删除聊天 |
| `PATCH` | `/api/aichat/history` | 重命名聊天 |
| `POST` | `/api/aichat/search-history` | 搜索聊天历史 |
| `GET` | `/api/aichat/recent-chats` | 获取最近聊天 |
| `POST` | `/api/aichat/search-recent-chats` | 搜索最近聊天 |

---

## 🚀 实时 AI 聊天 (AIRealTimeChat)

| 方法 | 路由 | 功能 |
|------|------|------|
| `POST` | `/api/airealtimechat/stream-test` | 测试实时流 |
| `POST` | `/api/airealtimechat/change-chat-title` | 更改标题 |
| `GET` | `/api/airealtimechat/chat-templates/{id?}` | 获取模板 |
| `PATCH` | `/api/airealtimechat/chat-templates` | 更新模板 |
| `DELETE` | `/api/airealtimechat/chat-templates/{id}` | 删除模板 |
| `GET` | `/api/airealtimechat/chat/{conver_id}` | 获取对话 |
| `GET` | `/api/airealtimechat/chat/{conver_id}/messages` | 获取消息 |
| `GET/POST` | `/api/airealtimechat/chat-send` | 发送消息 |
| `POST` | `/api/airealtimechat/new-chat` | 新建聊天 |
| `GET` | `/api/airealtimechat/history/{cat_slug}` | 获取历史 |
| `DELETE` | `/api/airealtimechat/history` | 删除聊天 |
| `PATCH` | `/api/airealtimechat/history` | 重命名聊天 |
| `GET` | `/api/airealtimechat/websocket-credentials` | 获取 WebSocket 凭证 |
| `POST` | `/api/airealtimechat/save-conversation` | 保存对话 |

---

## ✍️ AI 写手 (AIWriter)

### 生成器

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/aiwriter/generator/{slug}` | 获取生成器信息 |
| `GET` | `/api/aiwriter/generator/{slug}/workbook` | 获取工作簿信息 |

### 生成文本

| 方法 | 路由 | 功能 |
|------|------|------|
| `POST` | `/api/aiwriter/generate` | 生成内容 |
| `POST` | `/api/aiwriter/generate-output` | 流式文本输出 |
| `GET` | `/api/aiwriter/generate/lazyload` | 延迟加载图片 |
| `POST` | `/api/aiwriter/generate/save` | 保存生成内容 |

### OpenAI 列表

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/aiwriter/openai-list` | 获取 OpenAI 生成器列表 |
| `GET` | `/api/aiwriter/favorite-openai-list` | 获取收藏的生成器 |
| `POST` | `/api/aiwriter/favorite-openai-list-add` | 添加到收藏 |
| `POST` | `/api/aiwriter/favorite-openai-list-remove` | 从收藏删除 |

---

## 🖼️ AI 图像 (AIImage)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/aiimage/versions` | 获取模型版本 |
| `GET` | `/api/aiimage/check-availability` | 检查是否有活动生成 |
| `POST` | `/api/aiimage/generate-image` | 生成图像 |
| `GET` | `/api/aiimage/recent-images` | 获取最近 10 张图像 |

---

## 💳 支付 (Payment)

### 基本信息

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/payment` | 获取当前套餐 |
| `GET` | `/api/payment/check-revenue-cat` | 检查 RevenueCat 状态 |

### 套餐和订单

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/payment/plans/{plan_id?}` | 获取套餐列表 |
| `GET` | `/api/payment/orders/{order_id?}` | 获取订单列表 |

### 订阅

| 方法 | 路由 | 功能 |
|------|------|------|
| `POST` | `/api/payment/subscriptions/cancel-current` | 取消当前订阅 |

---

## 👥 推荐计划 (Affiliates)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/affiliates` | 获取推荐信息 |
| `GET` | `/api/affiliates/withdrawals` | 获取提现记录 |
| `POST` | `/api/affiliates/request-withdrawal` | 申请提现 |

---

## 🆘 支持 (Support)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/support` | 获取支持工单列表 |
| `POST` | `/api/support` | 创建新工单 |
| `GET` | `/api/support/ticket/{ticket_id}` | 获取工单详情 |
| `GET` | `/api/support/ticket/{ticket_id}/last-message` | 获取最后一条消息 |
| `POST` | `/api/support/send-message` | 发送消息 |
| `GET` | `/api/support/user/{ticket_id}` | 获取工单用户信息 |

---

## 📄 文档 (Documents)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/documents` | 获取所有文档 |
| `GET` | `/api/documents/doc/{id}` | 获取文档详情 |
| `POST` | `/api/documents/doc/{id}` | 保存文档 |
| `DELETE` | `/api/documents/doc/{id}` | 删除文档 |
| `GET` | `/api/documents/recent` | 获取最近文档 |
| `GET` | `/api/documents/all-openai` | 获取所有 OpenAI 生成器 |
| `GET` | `/api/documents/openai-filters` | 获取 OpenAI 过滤器 |

---

## 🔌 扩展 (Extensions)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/extensions` | 获取扩展列表 |
| 动态 | `/api/extensions/*` | 扩展特定 API 路由 |

---

## 🎤 品牌语音 (BrandVoice)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/brandvoice` | 获取品牌语音列表 |
| `GET` | `/api/brandvoice/{id}` | 获取品牌语音详情 |
| `POST` | `/api/brandvoice` | 创建品牌语音 |
| `DELETE` | `/api/brandvoice/{id}` | 删除品牌语音 |

---

## 🔊 AI 语音 (AIVoiceOver)

| 方法 | 路由 | 功能 |
|------|------|------|
| `POST` | `/api/aivoiceover/preview` | 预览语音 |
| `POST` | `/api/aivoiceover/generate` | 生成语音 |

---

## 🏷️ 实体管理 (Entity)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/entity/list` | 获取所有实体和令牌数 |

---

## 🛠️ AI 工具 (AI-Tools)

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/ai-tools` | 获取所有 AI 工具 |
| `GET` | `/api/ai-tools/category/{category}` | 按类别获取工具 |
| `GET` | `/api/ai-tools/{slug}` | 获取工具详情 |
| `GET` | `/api/ai-tools/{slug}/templates` | 获取工具模板 |
| `POST` | `/api/ai-tools/{slug}/execute` | 执行工具 |
| `GET` | `/api/ai-tools/{slug}/stats` | 获取工具统计 |

---

## 📰 新闻爬虫 (News)

### 公开端点

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/news` | 获取新闻列表 |
| `GET` | `/api/news/categories` | 获取新闻分类 |
| `GET` | `/api/news/trending` | 获取热门新闻 |
| `GET` | `/api/news/{news}` | 获取新闻详情 |
| `GET` | `/api/news/user/recommendations` | 获取用户推荐新闻 |

### 管理员端点

| 方法 | 路由 | 功能 |
|------|------|------|
| `GET` | `/api/news/sources/list` | 获取新闻源列表 |
| `POST` | `/api/news/sources` | 创建新闻源 |
| `PATCH` | `/api/news/sources/{source}` | 更新新闻源 |
| `DELETE` | `/api/news/sources/{source}` | 删除新闻源 |
| `POST` | `/api/news/sources/{source}/crawl-now` | 立即爬取 |
| `POST` | `/api/news/sources/{source}/crawl-async` | 异步爬取 |
| `GET` | `/api/news/sources/{source}/logs` | 获取爬取日志 |
| `POST` | `/api/news/{news}/publish` | 发布新闻 |
| `POST` | `/api/news/{news}/archive` | 存档新闻 |
| `POST` | `/api/news/{news}/reject` | 拒绝新闻 |

---

## 📊 API 统计

- **总端点数**: 50+
- **认证端点**: 19
- **应用配置**: 4
- **AI 聊天**: 20
- **实时聊天**: 12
- **AI 写手**: 12
- **AI 图像**: 4
- **支付**: 6
- **推荐**: 3
- **支持**: 6
- **文档**: 7
- **扩展**: 2+
- **其他**: 15+

---

## 🔑 认证方式

所有需认证的端点使用 **Laravel Sanctum** 令牌认证：

```bash
# 请求示例
curl -H "Authorization: Bearer {TOKEN}" \
     -H "Accept: application/json" \
     http://localhost:8000/api/user
```

---

## 📝 请求/响应格式

### 请求头

```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {TOKEN}
```

### 成功响应

```json
{
  "success": true,
  "data": { ... },
  "message": "操作成功"
}
```

### 错误响应

```json
{
  "success": false,
  "error": "错误信息",
  "errors": { ... }
}
```

---

## 🌐 基础 URL

- **本地开发**: `http://localhost:8000/api`
- **生产环境**: `https://mdio.shop/api`

---

## 📚 模块详解

### 1. 认证模块

- 用户注册、登录、登出
- 社交登录 (Google, Apple)
- 邮箱验证和密码重置
- 用户资料管理

### 2. AI 聊天系统

- 普通聊天和实时聊天
- 聊天模板管理
- 对话历史和搜索
- WebSocket 实时通信

### 3. AI 内容生成

- 文本生成 (AIWriter)
- 图像生成 (AIImage)
- 语音合成 (AIVoiceOver)

### 4. 商务功能

- 支付管理和订阅
- 推荐计划和佣金
- 额度管理

### 5. 用户支持

- 工单管理系统
- 文档存储和检索
- 品牌语音库

### 6. 新闻爬虫

- 新闻聚合和分类
- 热门新闻推荐
- 新闻源管理和爬取控制

---

## 🚀 使用示例

### 用户注册

```bash
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

### 发送聊天消息

```bash
POST /api/aichat/chat-send
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "conver_id": 1,
  "message": "Hello, AI!",
  "model": "gpt-4"
}
```

### 生成图像

```bash
POST /api/aiimage/generate-image
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "prompt": "A beautiful sunset",
  "size": "1024x1024",
  "model": "dall-e-3"
}
```

---

## ⚠️ 限制和注意

1. **限流**: 邮箱验证重发限制为 6 次/分钟
2. **认证**: 大多数 API 需要有效的 JWT 令牌
3. **权限**: 某些端点仅限管理员或特定用户角色
4. **订阅**: 某些功能需要活跃的付费订阅

---

## 🔍 扩展 API

扩展可以在 `routes/extapiroutes/` 目录添加自定义 API 路由，自动注册到 `/api/extensions` 前缀下。

---

*最后更新: 2026-01-09*
