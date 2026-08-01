FROM richarvey/nginx-php-fpm:3.1.6

# Instalar Node.js y npm sobre la imagen de PHP
RUN apk add --no-cache nodejs npm

COPY . .

ENV SKIP_COMPOSER 0
ENV WEBROOT /var/www/html/public
ENV PHP_ERRORS_STDERR 1
ENV RUN_SCRIPTS 1
ENV REAL_IP_HEADER 1
ENV APP_ENV production
ENV APP_DEBUG false
ENV LOG_CHANNEL stderr
ENV COMPOSER_ALLOW_SUPERUSER 1

# 1. Instalar dependencias de PHP (esto genera vendor/tightenco/ziggy)
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# 2. Instalar dependencias de JS y compilar (ahora sí encuentra ziggy)
RUN npm install && npm run build

# Ya que compilamos todo en el build, no hace falta reinstalar composer al iniciar
ENV SKIP_COMPOSER 1

CMD ["/start.sh"]