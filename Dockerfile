FROM wordpress:latest

# Dependency Installation
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y python3 vim less && \
    # WP-CLI Installation
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    # Enable Apache headers module
    a2enmod headers && \
    # MySQL
    apt-get install -y default-mysql-client && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copying Themes and Plugins into the WordPress image
# Uncomment and adjust these lines if you have custom themes or plugins
# COPY themes /usr/src/wordpress/wp-content/themes
# COPY plugins /usr/src/wordpress/wp-content/plugins

# Copying custom entrypoint script
COPY entrypoint-child.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint-child.sh

# Updating the configuration of WordPress image
# Uncomment and adjust these lines if you have custom configurations
# COPY ./config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
# COPY ./config/docker-apache.conf /etc/apache2/conf-enabled/docker-apache.conf

RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/g' /etc/apache2/sites-available/000-default.conf

# Copying custom health check file
COPY health-check.php /var/www/html/health-check.php

EXPOSE 8080

ENTRYPOINT ["entrypoint-child.sh"]
CMD ["apache2-foreground"]
