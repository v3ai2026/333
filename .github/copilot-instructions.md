# Copilot Instructions for MagicAI v9.9

## Project Overview

**MagicAI v9.9** is a comprehensive AI-powered platform featuring multi-agent collaboration, RAG (Retrieval-Augmented Generation), and advanced AI capabilities. 

### Core Technologies
- **Backend**: Python (FastAPI, Flask), Node.js
- **Frontend**: React, Next.js, TypeScript
- **AI/ML**: LangChain, LlamaIndex, OpenAI API, Anthropic Claude
- **Database**: PostgreSQL, Redis, Vector Databases (Pinecone/Weaviate)
- **Infrastructure**: Docker, Kubernetes, Vercel
- **Web Scraping**: Llama Spider integration

---

## Architecture Principles

### 1. Multi-Agent System
- Each agent has specialized capabilities (RAG, Search, Code Generation, etc.)
- Agents communicate via message queues and REST APIs
- Central orchestrator manages agent coordination

### 2. Microservices Architecture
```
magicai-v9/
├── backend-service/          # Core backend services
│   ├── api/                  # REST API endpoints
│   ├── agents/               # AI agent implementations
│   ├── services/             # Business logic
│   └── models/               # Data models
├── frontend/                 # React/Next.js frontend
├── brain-engine/             # AI reasoning engine
├── rag-service/              # RAG chatbot service
├── llama-spider/             # Web scraping service
└── infrastructure/           # Docker, K8s configs
```

### 3. Key Services

#### RAG Chatbot Service
- **Purpose**: Document Q&A with context retrieval
- **Stack**: LangChain + Vector DB
- **Endpoints**: `/api/chat`, `/api/upload-docs`

#### Brain Engine
- **Purpose**: Multi-agent orchestration and reasoning
- **Features**:  Task decomposition, agent selection, result synthesis

#### Llama Spider
- **Purpose**:  Intelligent web scraping
- **Capabilities**: Dynamic content extraction, anti-bot bypass

---

## Coding Guidelines

### Python Code Style
```python
# Use type hints
def process_query(query: str, context: List[str]) -> Dict[str, Any]:
    """Process user query with RAG context. 
    
    Args:
        query: User's question
        context: Retrieved document chunks
        
    Returns:
        Dict containing answer and sources
    """
    pass

# Use dataclasses for models
from dataclasses import dataclass

@dataclass
class AgentResponse:
    agent_id: str
    result: str
    confidence: float
```

### TypeScript/React Style
```typescript
// Use interfaces for props
interface ChatMessageProps {
  message: string;
  sender: 'user' | 'ai';
  timestamp: Date;
}

// Functional components with hooks
const ChatMessage: React.FC<ChatMessageProps> = ({ message, sender, timestamp }) => {
  return (
    <div className={`message ${sender}`}>
      <p>{message}</p>
      <span>{timestamp.toLocaleTimeString()}</span>
    </div>
  );
};
```

### API Design Patterns
```python
# FastAPI endpoint structure
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel

router = APIRouter(prefix="/api/v1")

class ChatRequest(BaseModel):
    query: str
    session_id: str
    context_limit: int = 5

@router.post("/chat")
async def chat(request: ChatRequest, user=Depends(get_current_user)):
    try:
        response = await rag_service.process(request.query)
        return {"status": "success", "data": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---

## Development Workflow

### 1. Local Development
```bash
# Install dependencies
make install

# Run backend services
make backend-dev

# Run frontend
make frontend-dev

# Run all services with Docker
make docker-up
```

### 2. Testing
```bash
# Run unit tests
make test

# Run integration tests
make test-integration

# Run with coverage
make test-coverage
```

### 3. Deployment
```bash
# Build Docker images
make docker-build

# Deploy to staging
make deploy-staging

# Deploy to production
make deploy-prod

# Vercel deployment
./vercel-deploy.sh
```

---

## Common Patterns

### 1. Agent Implementation
```python
from abc import ABC, abstractmethod

class BaseAgent(ABC):
    def __init__(self, config: AgentConfig):
        self.config
