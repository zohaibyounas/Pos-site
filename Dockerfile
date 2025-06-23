FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip curl libzip-dev libpng-dev libxml2-dev libicu-dev libonig-dev

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql mbstring zip bcmath intl

# Enable Apache rewrite and override
RUN a2enmod rewrite \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Set DocumentRoot to Laravel's public folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html/public

# Copy project files (this must come after setting DocumentRoot)
COPY . .

# Ensure Laravel .env exists
COPY .env.example .env

# Set correct permissions
RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Generate app key (if not already set)
RUN php artisan key:generate || true

# Clear and cache config
RUN php artisan config:clear && php artisan config:cache || true

# Install dependencies
ENV COMPOSER_MEMORY_LIMIT=-1
RUN composer install --no-dev --optimize-autoloader --no-scripts -vvv \
    || (echo "Composer failed. Checking Laravel log..." && cat storage/logs/laravel.log || true)

# Expose port 80
EXPOSE 80

# Run Apache
CMD ["apache2-foreground"]
