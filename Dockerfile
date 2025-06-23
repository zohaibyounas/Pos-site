FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip curl libzip-dev libpng-dev libxml2-dev libicu-dev libonig-dev

# Install PHP extensions separately
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install zip
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install intl

# Enable Apache rewrite module
RUN a2enmod rewrite

# Enable .htaccess override
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Set DocumentRoot to Laravel's public directory
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Copy env file if not already handled by CI/CD
COPY .env.example .env

# Set permissions for Laravel
RUN mkdir -p storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Increase Composer memory limit and install dependencies
ENV COMPOSER_MEMORY_LIMIT=-1

# Install dependencies (fallback to log on failure)
RUN composer install --no-dev --optimize-autoloader --no-scripts -vvv \
    || (echo "Composer failed. Checking Laravel log..." && cat storage/logs/laravel.log || true)

# Expose the default Apache port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
