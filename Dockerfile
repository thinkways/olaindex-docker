FROM thinkinn/alpine-nginx-php

RUN \
  rm -rf /var/www/index.php \
  rm -rf /etc/nginx/conf.d/default.conf
  
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
   && for i in `ls OLAINDEX* -A`;do mv OLAINDEX*/${i} /var/www/;done \
   && rm -r OLAINDEX* \
   && cp /var/www/.env.example /var/www/.env

WORKDIR /var/www/
RUN composer install -vvv    
RUN set -x \
   && chmod -R 755 storage \
   && chown -R www-data:www-data /var/www

EXPOSE 80
