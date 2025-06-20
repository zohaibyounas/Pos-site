FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy app code
COPY . .

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev

# Expose port
EXPOSE 8080

# Start PHP-FPM server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]
