FROM nginx

RUN rm /etc/nginx/conf.d/default.conf || echo "File does not exist"
RUN rm /etc/nginx/conf.d/example_ssl.conf || echo "File does not exist"

COPY config/nginx.conf /etc/nginx/
COPY config/default /etc/nginx/sites-enabled/
COPY html/index.html /etc/nginx/html/
