# Stage 1: Build frontend assets
FROM node:20-alpine AS node-builder
WORKDIR /app
COPY Magicai-Server-Files/package*.json ./
RUN npm ci

COPY Magicai-Server-Files/resources ./resources
COPY Magicai-Server-Files/tailwind*.js ./
COPY Magicai-Server-Files/postcss.config.js ./
RUN npm run build

# Stage 2: Final image with PHP, Nginx, and Supervisor
FROM php:8.2-fpm-alpine

# Install system dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    zip \
    unzip \
    git \
    mysql-client \
    postgresql-client \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    bcmath \
    ctype \
    fileinfo \
    json \
    mbstring \
    openssl \
    tokenizer \
    xml \
    zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure Nginx and Supervisor
COPY nginx.conf /etc/nginx/nginx.conf
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set up work directory and copy application files
WORKDIR /app
COPY Magicai-Server-Files/ ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy frontend build artifacts
COPY --from=node-builder /app/public/build ./public/build

# Set permissions
RUN chmod -R 755 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chown -R www-data:www-data /var/lib/nginx \
    && touch /run/nginx.pid \
    && chown -R www-data:www-data /run/nginx.pid

# Expose port and start supervisor
EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
