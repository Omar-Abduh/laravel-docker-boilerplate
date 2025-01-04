FROM nginx:stable-alpine3.20

RUN sed -i "s/user  nginx/user root/g" /etc/nginx/nginx.conf

ADD ./nginx/default.conf /etc/nginx/conf.d/

RUN mkdir -p /var/www/html
