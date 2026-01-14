# 🦙 LLamaSpider - Llama AI 爬蟲集成指南

## 快速開始

### 1. 安裝 Ollama

#### Windows

```bash
# 下載 Ollama
# https://ollama.ai/download

# 或使用 Scoop
scoop install ollama

# 或使用 Chocolatey
choco install ollama
```

#### macOS

```bash
brew install ollama
```

#### Linux

```bash
curl https://ollama.ai/install.sh | sh
```

### 2. 運行 Ollama 服務

```bash
ollama serve
# 服務運行在 http://localhost:11434
```

### 3. 下載 Llama 模型

在**新的終端窗口**執行：

```bash
# 下載 Llama2 (7B 模型, ~4GB)
ollama pull llama2

# 或下載 Llama3 (最新版本)
ollama pull llama3

# 或下載 Mistral (更快，7B)
ollama pull mistral

# 查看已下載的模型
ollama list
```

### 4. 安裝 Python 依賴

```bash
cd "c:\Users\Administrator\Desktop\333\MagicAI v9.9"

# 安裝依賴
pip install requests asyncio python-dotenv

# 或使用 requirements.txt
pip install -r requirements.txt
```

---

## 使用 LLamaSpider

### 方式 1: 直接使用

```python
from scripts.llama_spider_ai import LlamaSpiderAI, LlamaConfig

# 初始化配置
config = LlamaConfig(
    model="llama2",
    base_url="http://localhost:11434",
    temperature=0.7
)

# 創建 AI 爬蟲
ai_spider = LlamaSpiderAI(config)

# 提取商品信息
product_html = "<div>商品信息...</div>"
info = ai_spider.extract_product_info(product_html)
print(info)

# 情感分析
review = "這個產品很不錯"
sentiment = ai_spider.analyze_sentiment(review)
print(sentiment)

# 內容總結
summary = ai_spider.summarize("很長很長的文本...")
print(summary)
```

### 方式 2: 與基礎爬蟲結合

```python
from scripts.python_spider_best_practices import IntegratedCrawler, CrawlerConfig
from scripts.llama_spider_ai import LlamaSpiderAI, LlamaConfig

# 創建基礎爬蟲
crawler_config = CrawlerConfig(
    name='淘寶爬蟲 + AI分析',
    spider_type='taobao',
    start_urls=['https://www.taobao.com'],
    use_user_agent_rotation=True
)
crawler = IntegratedCrawler(crawler_config)

# 創建 AI 分析器
ai_config = LlamaConfig(model="llama2")
ai_spider = LlamaSpiderAI(ai_config)

# 爬蟲數據 + AI 分析
async def process_data():
    # 爬取數據
    stats = await crawler.run()
    
    # 用 AI 分析爬取的商品
    for item in crawler.data_aggregator.get_all():
        product_info = ai_spider.extract_product_info(item['html'])
        sentiment = ai_spider.analyze_sentiment(item['review'])
        
        print(f"商品: {product_info}")
        print(f"評價情感: {sentiment}")
```

### 方式 3: 批量處理

```python
import asyncio

async def batch_process():
    ai_spider = LlamaSpiderAI()
    
    items = [
        {'url': 'http://...', 'html': '<div>...</div>'},
        {'url': 'http://...', 'html': '<div>...</div>'},
    ]
    
    # 批量提取
    results = await ai_spider.batch_extract(items, 'product')
    
    for result in results:
        print(result)

asyncio.run(batch_process())
```

---

## 支持的提取類型

### 1. 商品信息提取

```python
html = "<div class='product'>...</div>"
info = ai_spider.extract_product_info(html)

# 返回:
# {
#     "title": "商品名稱",
#     "price": "¥199.99",
#     "rating": "4.8/5",
#     "shop": "官方旗艦店",
#     "tags": ["標籤1", "標籤2"]
# }
```

### 2. 電影信息提取

```python
html = "<div class='movie'>...</div>"
info = ai_spider.extract_movie_info(html)

# 返回:
# {
#     "title": "電影名稱",
#     "year": 2024,
#     "rating": 8.5,
#     "director": "導演名",
#     "cast": ["演員1", "演員2"],
#     "genres": ["科幻", "動作"]
# }
```

### 3. 職位信息提取

```python
html = "<div class='job'>...</div>"
info = ai_spider.extract_job_info(html)

# 返回:
# {
#     "title": "Python開發工程師",
#     "company": "某科技公司",
#     "location": "北京",
#     "salary": "15K-25K",
#     "experience": "3-5年",
#     "requirements": ["Python", "Django"]
# }
```

### 4. 內容總結

```python
content = "很長很長的文章..."
summary = ai_spider.summarize(content, max_length=200)
```

### 5. 情感分析

```python
review = "這個產品真的很不錯！"
sentiment = ai_spider.analyze_sentiment(review)

# 返回:
# {
#     "sentiment": "positive",
#     "confidence": 0.95,
#     "keywords": ["不錯", "產品"]
# }
```

---

## 配置選項

```python
from scripts.llama_spider_ai import LlamaConfig

config = LlamaConfig(
    model="llama2",              # 模型名稱
    base_url="http://localhost:11434",  # Ollama 服務地址
    temperature=0.7,             # 溫度 (0-1, 越高越創意)
    top_p=0.9,                  # Top-P 採樣
    max_tokens=2048,            # 最大生成詞數
    timeout=60                  # 超時時間(秒)
)
```

### 推薦模型

| 模型 | 大小 | 速度 | 質量 | 適用場景 |
|------|------|------|------|---------|
| **llama2** | 7B | 中 | 高 | 通用提取、分析 |
| **llama3** | 8B | 中 | 非常高 | 複雜任務、精細分析 |
| **mistral** | 7B | 快 | 中 | 快速提取、簡單任務 |
| **neural-chat** | 7B | 快 | 中 | 對話、互動任務 |

---

## 常見問題

### Q1: Ollama 無法連接？

```bash
# 檢查 Ollama 是否運行
ollama list

# 如果命令失敗，啟動 Ollama 服務
ollama serve

# 測試連接
curl http://localhost:11434/api/tags
```

### Q2: 模型下載很慢？

- Llama2 需要 ~4GB 下載
- 建議用國內鏡像或使用更小的模型 (Mistral)
- 可以後台運行，同時進行其他工作

### Q3: 如何切換模型？

```python
config = LlamaConfig(model="mistral")  # 改成更快的模型
ai_spider = LlamaSpiderAI(config)
```

### Q4: GPU 加速支持？

```bash
# 如果有 NVIDIA GPU
# Ollama 會自動使用 CUDA 加速

# 查看使用情況
nvidia-smi
```

### Q5: 如何自訂提取邏輯？

```python
from scripts.llama_spider_ai import DataExtractionPrompt

# 添加自訂提示詞
custom_prompt = """
請提取以下數據...
"""

response = ai_spider.client.generate(custom_prompt)
```

---

## 性能優化

### 1. 使用更小的模型

```python
config = LlamaConfig(model="mistral")  # 比 llama2 快 2-3 倍
```

### 2. 批量處理

```python
# ✓ 好 - 批量處理
results = await ai_spider.batch_extract(items, 'product')

# ✗ 差 - 逐個處理
for item in items:
    result = ai_spider.extract_product_info(item['html'])
```

### 3. 緩存結果

```python
# 避免重複提取相同內容
ai_spider.extraction_cache[content_hash] = result
```

### 4. 異步執行

```python
import asyncio

# 並行執行多個提取任務
tasks = [
    ai_spider.generate_async(prompt1),
    ai_spider.generate_async(prompt2),
    ai_spider.generate_async(prompt3),
]
results = await asyncio.gather(*tasks)
```

---

## 完整示例：電商爬蟲 + AI 分析

```python
import asyncio
from scripts.llama_spider_ai import LlamaSpiderAI, LlamaConfig
from scripts.python_spider_best_practices import IntegratedCrawler, CrawlerConfig

async def ecommerce_crawler_with_ai():
    # 配置爬蟲
    crawler_config = CrawlerConfig(
        name='淘寶爬蟲',
        spider_type='taobao',
        start_urls=['https://s.taobao.com/search?q=python書籍'],
        use_user_agent_rotation=True,
        request_delay_range=(2, 5)
    )
    
    # 配置 AI
    ai_config = LlamaConfig(
        model="llama2",
        temperature=0.5  # 降低溫度提高準確性
    )
    
    # 初始化
    crawler = IntegratedCrawler(crawler_config)
    ai_spider = LlamaSpiderAI(ai_config)
    
    # 爬取數據
    await crawler.run()
    
    # AI 分析
    results = []
    for item in crawler.data_aggregator.get_all()[:10]:  # 前 10 個
        product_info = ai_spider.extract_product_info(item.get('html', ''))
        results.append({
            'url': item['url'],
            'ai_extracted': product_info,
            'timestamp': item.get('timestamp')
        })
        
        await asyncio.sleep(0.5)
    
    return results

# 運行
results = asyncio.run(ecommerce_crawler_with_ai())
for result in results:
    print(result)
```

---

## 集成到 MagicAI Laravel

在 Laravel 服務中調用 LLamaSpider：

```php
// Magicai-Server-Files/app/Services/Ai/LlamaSpiderService.php

namespace App\Services\Ai;

class LlamaSpiderService {
    public function extractProductInfo($html) {
        $pythonScript = 'python scripts/llama_spider_ai.py';
        // 調用 Python 腳本
    }
}
```

---

## 下一步

1. ✅ 安裝 Ollama 和 Llama 模型
2. ✅ 運行集成測試: `python scripts/llama_spider_ai.py`
3. ✅ 集成到您的爬蟲項目
4. ✅ 微調提示詞以優化結果

**准備好了嗎？** 🚀
