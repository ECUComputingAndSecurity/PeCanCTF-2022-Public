FROM alpine:3.13

# Setup user
RUN adduser -D -u 1000 -g 1000 -s /bin/sh plex

# Install system packages
RUN apk add --no-cache --update php7-fpm nginx supervisor

# Configure php-fpm and nginx
COPY config/fpm.conf /etc/php7/php-fpm.d/www.conf
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/supervisord.conf /etc/supervisord.conf

# Import script to reset logs, cron to run every 5 minutes
COPY config/resetlogfile.sh /root/resetlogfile.sh
COPY config/resetlog.cron /etc/cron.d/resetlog.cron

RUN chmod +x /root/resetlogfile.sh && chmod 644 /etc/cron.d/resetlog.cron && \
	crontab /etc/cron.d/resetlog.cron;

# Copy challenge files
COPY src /var/www/html

RUN echo "pecan{p0is0n_l0g_ex3cute_c0de}" > /flag

# Setup permissions
RUN chown -R plex:plex /var/lib/nginx

# Expose the port nginx is listening on
EXPOSE 80

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN ["chmod","+x","entrypoint.sh"]
ENTRYPOINT [ "/entrypoint.sh" ] 

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
