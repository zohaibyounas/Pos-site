FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip curl libzip-dev libpng-dev libxml2-dev libicu-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath tokenizer intl

# Enable Apache rewrite module
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Copy env file if not already handled by your CI/CD
COPY .env.example .env

# Set permissions for Laravel
RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Increase Composer memory limit and install dependencies
ENV COMPOSER_MEMORY_LIMIT=-1

# Use safer install command with fallback logs
RUN composer install --no-dev --optimize-autoloader --no-scripts -vvv \
    || (echo "Composer failed. Checking Laravel log..." && cat storage/logs/laravel.log || true)

# Expose the port Render expects (Apache default is 80, but use 8080 if Render is configured for it)
EXPOSE 8080

# Start Apache in foreground
CMD ["apache2-foreground"]
