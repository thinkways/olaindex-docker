FROM ej52/alpine-nginx-php
RUN rm -rf /var/www/index.php \
  && rm -rf /etc/nginx/conf.d/default.conf \
  && echo \
  'server {
    listen       80;
    server_name  _;
    root   /var/www/public;

	  add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;
    index  index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
		    # NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
        fastcgi_pass unix:/var/run/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_index index.php;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
   }' > /etc/nginx/conf.d/default.conf
  
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
