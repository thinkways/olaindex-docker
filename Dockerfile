FROM ej52/alpine-nginx-php
RUN rm -rf /var/www/index.php \
  && rm -rf /etc/nginx/conf.d/default.conf \
  && mv default.conf /etc/nginx/conf.d
  
WORKDIR /var/www/
RUN wget https://github.com/WangNingkai/OLAINDEX/archive/5.0.zip \
   && unzip *.zip \
   && rm *.zip \
   && mv OLAINDEX*/* ./
   
RUN cp .env.example .env && cp database/database.sample.sqlite database/database.sqlite
RUN composer install -vvv
RUN set -x \
  && php artisan key:generate \
  && php artisan migrate \
  && php artisan db:seed \
  && chmod -R 755 storage \
  && chown -R www-data:www-data /var/www

EXPOSE 8001
