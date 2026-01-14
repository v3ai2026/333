version: '3.8'
services:
  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: moda.STUDIO
      MYSQL_USER: moda.STUDIO
      MYSQL_PASSWORD: secret
    volumes:
      - db_data:/var/lib/mysql
    ports:
      - "3306:3306"

  redis:
    image: redis:7
    restart: always
    ports:
      - "6379:6379"

  web:
    build:
      context: ./moda.STUDIO-Server-Files
      dockerfile: Dockerfile
    depends_on:
      - db
      - redis
    environment:
      APP_ENV: local
      APP_DEBUG: 'true'
      DB_HOST: db
      DB_DATABASE: moda.STUDIO
      DB_USERNAME: moda.STUDIO
      DB_PASSWORD: secret
      BROADCAST_DRIVER: redis
      QUEUE_CONNECTION: redis
      VERTEX_AI_BACKEND_URL: http://python-backend:8080
    volumes:
      - ./moda.STUDIO-Server-Files:/var/www/html
      - ./storage:/var/www/html/storage
    ports:
      - "8000:8000"

  python-backend:
    build:
      context: ./backend-service
      dockerfile: Dockerfile
    depends_on:
      - db
    environment:
      GCP_PROJECT_ID: your-gcp-project
      GCP_REGION: your-region
    ports:
      - "8080:8080"

volumes:
  db_data:FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
ENV PYTHONUNBUFFERED=1
CMD ["python", "app.py"]
