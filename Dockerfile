# Choose the desired PHP version
# Choices available at https://hub.docker.com/_/php/ stick to "-cli" versions recommended
FROM php:7.4-cli-buster

MAINTAINER Sbit.io <soporte@sbit.io>

ENV TARGET_DIR="/usr/local/lib/php-qa" \
    COMPOSER_ALLOW_SUPERUSER=1 \
    TIMEZONE=Europe/Madrid \
    LOCALE=es_ES.UTF-8 \
    LOCALE_CHARSET=UTF-8 \
    PHP_MEMORY_LIMIT=1G

ENV PATH=$PATH:$TARGET_DIR/vendor/bin

RUN mkdir -p $TARGET_DIR

WORKDIR $TARGET_DIR

RUN echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list \
 && apt-get update -qq \
 && echo "locales locales/default_environment_locale select $LOCALE" | debconf-set-selections \
 && echo "locales locales/locales_to_be_generated select $LOCALE $LOCALE_CHARSET" | debconf-set-selections \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -yqq -o=Dpkg::Use-Pty=0 \
      locales \
      wget \
      zip \
      python3-pkg-resources \
      git \
      libxml2-dev \
      libxslt-dev \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -yqq -o=Dpkg::Use-Pty=0 \
    -t buster-backports yamllint \
 && docker-php-ext-install xml xsl \
 && docker-php-ext-install -j$(nproc) mysqli \
 && docker-php-ext-install -j$(nproc) pdo_mysql \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean -yqq


ENV LANG=$LOCALE
ENV LANGUAGE=$LOCALE
ENV LC_ALL=$LOCALE

RUN echo "[PHP]\nmemory_limit=${PHP_MEMORY_LIMIT}" >> $PHP_INI_DIR/conf.d/overrides.ini

COPY composer-installer.sh $TARGET_DIR/
COPY composer-wrapper.sh /usr/local/bin/composer

RUN chmod 744 $TARGET_DIR/composer-installer.sh
RUN chmod 744 /usr/local/bin/composer

# Run composer installation of needed tools
RUN $TARGET_DIR/composer-installer.sh \
 && composer selfupdate \
 && composer require --prefer-stable --prefer-dist \
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
       "edgedesign/phpqa" \
         # phpqa suggested tools
         # See https://github.com/EdgedesignCZ/phpqa/blob/master/bin/suggested-tools.sh#L16
         "php-parallel-lint/php-parallel-lint" \
         "php-parallel-lint/php-console-highlighter" \
         "phpstan/phpstan" \
         # phpstan dependency
           "nette/neon" \
         "qossmic/deptrac-shim" \
         "friendsofphp/php-cs-fixer:>=2" \
         "vimeo/psalm:>=2" \
         "sensiolabs/security-checker"
