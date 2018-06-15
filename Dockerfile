FROM debian:jessie
MAINTAINER Purvesh Patel <ind.purvesh@gmail.com>

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/sites-available/

RUN echo "upstream php-upstream { server php-fpm:9000; }" > /etc/nginx/conf.d/upstream.conf

RUN usermod -u 1000 www-data

CMD ["nginx"]

EXPOSE 80
EXPOSE 443
