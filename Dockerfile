FROM ubuntu:bionic
MAINTAINER Alex Pukhlov <alexcobramk3@gmail.com>

# Set env specific configs
ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_USER=mysql
ENV MYSQL_DATA_DIR=/var/lib/mysql
ENV MYSQL_RUN_DIR=/run/mysqld
ENV MYSQL_LOG_DIR=/var/log/mysql

# Optional env vars you can declare if you desire
ENV MYSQL_ROOT_PASSWORD=root
#ENV MYSQL_ALLOW_EMPTY_PASSWORD=yes
#ENV MYSQL_RANDOM_ROOT_PASSWORD=yes
#ENV MYSQL_ONETIME_PASSWORD=yes
#ENV MYSQL_USER=user
#ENV MYSQL_PASSWORD=password
#ENV MYSQL_DATABASE=list,of,databases,to,create

# Add mysql user to run the service
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Sync apt-get ready for installation
RUN apt-get update

# Install MySQL dependencies
RUN apt-get install -y --no-install-recommends pwgen openssl perl tzdata
RUN mkdir -p /var/lib/mysql && mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/lib/mysql && chown -R mysql:mysql /var/run/mysqld && chmod 777 /var/run/mysqld

# Run update and install mysql-server
RUN apt-get install -y mysql-server && rm -rf ${MYSQL_DATA_DIR} && rm -rf /var/lib/apt/lists/*

# Comment out a few problematic configuration values
# don't reverse lookup hostnames, they are usually another container
RUN sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

# https://github.com/docker-library/mysql/blob/eeb0c33dfcad3db46a0dfb24c352d2a1601c7667/5.7/Dockerfile#L20
RUN mkdir /docker-entrypoint-initdb.d

# Create a volume for holding data
VOLUME /var/lib/mysql

EXPOSE 3306

RUN apt-get update && apt-get install -y --no-install-recommends \
		apache2 \
		software-properties-common \
	&& apt-get clean \
	&& rm -fr /var/lib/apt/lists/*

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update && apt-get install -y --no-install-recommends \
		libapache2-mod-php7.2 \
		php7.2 \
		php7.2-bcmath \
		php7.2-cli \
		php7.2-curl \
		php7.2-dev \
		php7.2-gd \
		php7.2-imap \
		php7.2-intl \
		php7.2-mbstring \
		php7.2-mysql \
		php7.2-pgsql \
		php7.2-pspell \
		php7.2-xml \
		php7.2-xmlrpc \
		php-apcu \
		php-memcached \
		php-pear \
		php-redis \
	&& apt-get clean \
	&& rm -fr /var/lib/apt/lists/*

EXPOSE 80
CMD ["/run.sh"]
