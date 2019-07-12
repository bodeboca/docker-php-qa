#!/bin/sh

php /usr/local/lib/php-qa/composer.phar $@
STATUS=$?
return $STATUS
