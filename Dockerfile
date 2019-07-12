# Choose the desired PHP version
# Choices available at https://hub.docker.com/_/php/ stick to "-cli" versions recommended
FROM php:7.2-cli-stretch

MAINTAINER Sbit.io <soporte@sbit.io>

ENV TARGET_DIR="/usr/local/lib/php-qa" \
    COMPOSER_ALLOW_SUPERUSER=1 \
    TIMEZONE=Europe/Madrid \
    PHP_MEMORY_LIMIT=1G

ENV PATH=$PATH:$TARGET_DIR/vendor/bin

RUN mkdir -p $TARGET_DIR

RUN echo "[PHP]\nmemory_limit=${PHP_MEMORY_LIMIT}" >> $PHP_INI_DIR/conf.d/overrides.ini

WORKDIR $TARGET_DIR

COPY composer-installer.sh $TARGET_DIR/
COPY composer-wrapper.sh /usr/local/bin/composer

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get install -y zip && \
    apt-get install -y yamllint && apt-get install -y python3-pkg-resources && \
    apt-get install -y git && \
    apt-get install -y libxml2-dev && \
    apt-get install -y libxslt-dev && \
    docker-php-ext-install xml xsl

RUN chmod 744 $TARGET_DIR/composer-installer.sh
RUN chmod 744 /usr/local/bin/composer

# Run composer installation of needed tools
RUN $TARGET_DIR/composer-installer.sh && \
   composer selfupdate && \
   composer require --prefer-stable --prefer-source "hirak/prestissimo:^0.3" && \
   composer require --prefer-stable --prefer-dist \
       "squizlabs/php_codesniffer:^3.0" \
       "phpunit/phpunit:^8.0" \
       "phploc/phploc:^4.0" \
       "pdepend/pdepend:^2.5" \
       "phpmd/phpmd:^2.6" \
       "sebastian/phpcpd:^4.1" \
       "friendsofphp/php-cs-fixer:^2.14" \
       "phpcompatibility/php-compatibility:^9.0" \
       "phpmetrics/phpmetrics:^2.4" \
       "phpstan/phpstan:^0.11" \
       "drupal/coder:^8.3.1" \
       "dealerdirect/phpcodesniffer-composer-installer" \
       "mglaman/phpstan-drupal" \
       #"edgedesign/phpqa" \
       "jakub-onderka/php-parallel-lint" \
       "jakub-onderka/php-console-highlighter" \
       "phpstan/phpstan" \
       "friendsofphp/php-cs-fixer:~2.2" \
       "vimeo/psalm" \
       "sensiolabs/security-checker"

RUN composer config repositories.jonhattan-phpqa git https://github.com/jonhattan/phpqa.git && \
   composer require --prefer-stable --prefer-dist \
   "edgedesign/phpqa:dev-integration"
