# Etapa 1: instalar dependencias de PHP con Composer
FROM composer:2 AS vendor
WORKDIR /app
COPY database/ database/
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs --no-scripts

# Etapa 2: compilar assets con Node 20 (aquí sí existe Vite 7 compatible)
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=vendor /app/vendor ./vendor
COPY . .
RUN npm install && npm run build

# Etapa 3: imagen final con PHP + Nginx
FROM richarvey/nginx-php-fpm:3.1.6
COPY . .
COPY --from=vendor /app/vendor ./vendor
COPY --from=build /app/public/build ./public/build

ENV SKIP_COMPOSER 1
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr
ENV COMPOSER_ALLOW_SUPERUSER 1

CMD ["/start.sh"]