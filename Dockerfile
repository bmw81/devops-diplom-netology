FROM nginx:alpine

# Копируем статические файлы
COPY index.html /usr/share/nginx/html/index.html

# Создаём скрипт для отдачи hostname
RUN echo '#!/bin/sh' > /usr/share/nginx/html/hostname && \
    echo 'echo $(hostname)' >> /usr/share/nginx/html/hostname && \
    chmod +x /usr/share/nginx/html/hostname

# Настраиваем Nginx для отдачи hostname
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen 80;' >> /etc/nginx/conf.d/default.conf && \
    echo '    server_name localhost;' >> /etc/nginx/conf.d/default.conf && \
    echo '    location / { root /usr/share/nginx/html; index index.html; }' >> /etc/nginx/conf.d/default.conf && \
    echo '    location /hostname { alias /usr/share/nginx/html/hostname; default_type text/plain; }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
