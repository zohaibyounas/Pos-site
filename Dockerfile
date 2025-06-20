FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory inside container
WORKDIR /var/www

# Copy Laravel app (everything from current folder)
COPY . /var/www

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --verbose

# Set permissions for storage and cache
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 8000

# Start Laravel app
CMD php artisan serve --host=0.0.0.0 --port=8000
