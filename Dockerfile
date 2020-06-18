FROM trafex/alpine-nginx-php7:latest
COPY --from=composer /usr/bin/composer /usr/bin/composer 
RUN composer install --optimize-autoloader --no-interaction --no-progress

USER root
RUN  echo \
  $'server {\n\
    listen       80;\n\
    server_name  _;\n\
    root   /var/www/public;\n\
    add_header X-Frame-Options "SAMEORIGIN";\n\
    add_header X-XSS-Protection "1; mode=block";\n\
    add_header X-Content-Type-Options "nosniff";\n\
    charset utf-8;\n\
    index  index.php index.html index.htm;\n\
    location / {\n\
        try_files $uri $uri/ /index.php?$query_string;\n\
    }\n\
    location = /favicon.ico { access_log off; log_not_found off; }\n\
    location = /robots.txt  { access_log off; log_not_found off; }\n\
    error_page 404 /index.php;\n\
    location ~ \.php$ {\n\
        fastcgi_split_path_info ^(.+\.php)(/.+)$;\n\
        fastcgi_pass unix:/var/run/php-fpm.sock;\n\
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\n\
        fastcgi_index index.php;\n\
        include fastcgi_params;\n\
    }\n\
    location ~ /\.(?!well-known).* {\n\
        deny all;\n\
    }\n\
   }' > /etc/nginx/conf.d/default.conf  

RUN wget https://github.com/WangNingkai/OLAINDEX/archive/5.0.zip \
   && unzip *.zip \
   && rm *.zip \
   && for i in `ls OLAINDEX* -A`;do mv OLAINDEX*/${i} /var/www/html/;done \
   && rm -r OLAINDEX* \
   && cp /var/www/html/.env.example /var/www/html/.env

WORKDIR /var/www/html
RUN composer install -vvv    
RUN set -x \
   && php artisan key:generate \
   && php artisan migrate \
   && php artisan db:seed \
   && chmod -R 755 storage

EXPOSE 8080
