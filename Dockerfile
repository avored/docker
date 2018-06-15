FROM nginx:alpine
MAINTAINER Purvesh Patel <ind.purvesh@gmail.com>

ADD ./default.conf /etc/nginx/conf.d/default.conf
WORKDIR /var/www
