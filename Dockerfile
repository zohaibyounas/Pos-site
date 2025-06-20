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

# Set permissions early (some scripts need write access)
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# 🐛 Install dependencies without running post-scripts (for debugging)
RUN composer install --no-dev --optimize-autoloader --no-scripts || true

# ⛔ REMOVE this line if the issue is inside post-scripts
# RUN php artisan optimize || true

EXPOSE 8000

# Start a shell for debugging — you can exec into the container
CMD ["/bin/bash"]
