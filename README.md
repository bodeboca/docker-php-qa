# php-qa
[![DockerHub Badge](http://dockeri.co/image/sbitio/php-qa)](https://hub.docker.com/r/sbitio/php-qa/)

The objective is to include multiple PHP code quality tools in an easy to use Docker image. The
tools include PHP static analysis, lines of PHP code report, mess detector, code smell highlighting,
copy/paste detection, and the applications compatibility from one version of PHP to another for modernization.

More specifically this includes:

- squizlabs/php_codesniffer
- phpunit/phpunit
- phploc/phploc
- pdepend/pdepend
- phpmd/phpmd
- sebastian/phpcpd
- friendsofphp/php-cs-fixer
- phpcompatibility/php-compatibility
- phpmetrics/phpmetrics
- phpstan/phpstan
- edgedesign/phpqa

## Usage

Note: This image does nothing when invoking it without a followup command, such as:

```bash
cd </path/to/desired/directory>
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest <desired-command-with-arguments>
```

Windows users: The use of "$PWD" for present working directory will not work as expected, instead use the full path.
Such as "//c/Users/sbitio/project".

In the example above, Docker runs an interactive terminal to be removed when all is completed, and mounts
the current host directory ($PWD) inside the container, sets this as the current working directory, and then
loads the image sbitio/php-qa. Following this the user can add any commands to be executed inside
the container. (such as running the tools provided by the image)

This is the most common use case, enabling the user to run the tools on everything in and/or below the working
directory.

Available commands provided by the sbitio/php-qa image:

* php + args
* composer + args
* phpqa + args
* vendor/bin/phploc + args
* vendor/bin/phpmd + args
* vendor/bin/pdepend + args
* vendor/bin/phpcpd + args
* vendor/bin/phpmetrics + args
* vendor/bin/phpunit + args
* vendor/bin/phpcs + args
* vendor/bin/php-cs-fixer + args
* vendor/bin/phpstan + args (more robust commands via config file)
* sh (or any other command) + args
* yamllint

### Some example commands:

NOTE: If using the commands below "as-is", please create a 'php_code_quality' folder within the project first.
This will be used, by the commands, to contain the results of the various tools. Modify as desired.

IMPORTANT: If you run into memory issues, where the output states the process ran out of memory, you can alter the amount
of memory the PHP process uses for a given command by adding the -d flag to the PHP command. Note that the following example
is for extreme cases since the image already sets the memory limit to 512M.

```
php -d memory_limit=1G
```

#### PHPQA

See https://github.com/EdgedesignCZ/phpqa for more usage details of this tool, its a very convenient wrapper for most of the tools included.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest \
  phpqa --report offline
```

#### PHP Lines of Code (PHPLoc)

See https://github.com/sebastianbergmann/phploc for more usage details of this tool.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest \
  phploc -v --names "*.php" \
    --exclude "vendor" . > ./php_code_quality/phploc.txt
```

#### PHP Mess Detector (phpmd)

See https://phpmd.org/download/index.html for more usage details of this tool.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest \
  phpmd . xml codesize --exclude 'vendor' \
    --reportfile './php_code_quality/phpmd_results.xml'
```

#### PHP Depends (Pdepend)

See https://pdepend.org/ for more usage details of this tool.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest \
  pdepend --ignore='vendor' \
    --summary-xml='./php_code_quality/pdepend_output.xml' \
    --jdepend-chart='./php_code_quality/pdepend_chart.svg' \
    --overview-pyramid='./php_code_quality/pdepend_pyramid.svg' .
```

#### PHP Copy/Paste Detector (phpcpd)

See https://github.com/sebastianbergmann/phpcpd for more usage details of this tool.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest \
  phpcpd . \
    --exclude 'vendor' > ./php_code_quality/phpcpd_results.txt
```

#### PHPMetrics

See http://www.phpmetrics.org/ for more usage details of this tool.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest \
  phpmetrics --excluded-dirs 'vendor' \
    --report-html=./php_code_quality/metrics_results .
```

#### PHP Codesniffer (phpcs)

See https://github.com/squizlabs/PHP_CodeSniffer/wiki for more usage details of this tool.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest \
  phpcs -sv --extensions=php --ignore=vendor \
    --report-file=./php_code_quality/codesniffer_results.txt .
```

#### PHPCompatibility rules applied to PHP Codesniffer

See https://github.com/PHPCompatibility/PHPCompatibility and https://github.com/squizlabs/PHP_CodeSniffer/wiki for more
usage details of this tool.

```bash
docker run -it --rm -v "$PWD":/app -w /app sbitio/php-qa:latest sh -c \
  'phpcs -sv --config-set installed_paths  /usr/local/lib/php-qa/vendor/phpcompatibility/php-compatibility \
    && phpcs -sv --standard='PHPCompatibility' --extensions=php --ignore=vendor . \
         --report-file=./php_code_quality/phpcompatibility_results.txt .'
```

## Alternative Preparations

Rather than allowing Docker to retrieve the image from Docker Hub, users could also build the docker image locally
by cloning the image repo from Github.

Why? As an example, a different version of PHP provided by including a different PHP image may be desired. Or a
specific version of the tools loaded by Composer might be required.

After cloning, navigate to the location:

```bash
git clone https://github.com/sbitio/php-qa.git
cd php-code-quality
```

Alter the Dockerfile as desired, then build the image locally: (don't miss the dot at the end)

```bash
docker build -t sbitio/php-qa .
```

Or a user may simply desire the image as-is, for later use:

```bash
docker build -t sbitio/php-qa https://github.com/sbitio/php-qa.git
```

## Enjoy!

Please star, on Docker Hub and Github, if you find this helpful.
