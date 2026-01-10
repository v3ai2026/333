FROM python:3.11-slim

WORKDIR /app

# 系統依賴
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 複製依賴文件
COPY requirements.txt .

# 安裝 Python 依賴
RUN pip install --no-cache-dir -r requirements.txt

# 複製應用文件
COPY scripts/ ./scripts/

# 安裝 Ollama
RUN curl -fsSL https://ollama.ai/install.sh | sh

# 暴露端口
EXPOSE 11434
EXPOSE 5000
EXPOSE 8000

# 啟動命令
CMD ["sh", "-c", "ollama serve & python scripts/llama_spider_ai.py"]
