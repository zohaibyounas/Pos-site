FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath tokenizer intl

RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Copy env file
COPY .env.example .env

# Set permissions
RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Enable composer memory and run install with debugging
ENV COMPOSER_MEMORY_LIMIT=-1
RUN ls -al && composer install --no-dev --optimize-autoloader --no-scripts -vvv || cat storage/logs/laravel.log || true

EXPOSE 8080

CMD ["apache2-foreground"]
