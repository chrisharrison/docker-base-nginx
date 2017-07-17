FROM phusion/baseimage
MAINTAINER Chris Harrison <c.harrison1988@gmail.com>

# ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# setup
ENV HOME /root
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
WORKDIR /var/www

CMD ["/sbin/my_init"]

# apt-get
RUN DEBIAN_FRONTEND="noninteractive" apt-get install software-properties-common
RUN DEBIAN_FRONTEND="noninteractive" add-apt-repository ppa:ondrej/php
RUN DEBIAN_FRONTEND="noninteractive" apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y upgrade
RUN DEBIAN_FRONTEND="noninteractive" apt-get update --fix-missing

# php
RUN DEBIAN_FRONTEND="noninteractive" apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y upgrade
RUN DEBIAN_FRONTEND="noninteractive" apt-get update --fix-missing
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.1
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install php7.1-fpm php7.1-common php7.1-cli php7.1-mysqlnd php7.1-mcrypt php7.1-curl php7.1-bcmath php7.1-mbstring php7.1-soap php7.1-xml php7.1-zip php7.1-json php7.1-imap php-xdebug php-pgsql

RUN mkdir -p /root/setup
ADD build/php-setup.sh /root/setup/php-setup.sh
RUN chmod +x /root/setup/php-setup.sh
RUN (cd /root/setup/; /root/setup/php-setup.sh)

ADD build/phpfpm.sh /etc/service/phpfpm/run
RUN chmod +x /etc/service/phpfpm/run

# nginx
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y nginx-full

ADD build/nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

# git
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y git

# apt-get clean
RUN apt-get clean
RUN apt-get autoclean

# composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# disable services start
RUN update-rc.d -f apache2 remove
RUN update-rc.d -f nginx remove
RUN update-rc.d -f php7.0-fpm remove

# web folders
RUN rm -rf /var/www/*
RUN mkdir -p /var/www
RUN chown -R www-data:www-data /var/www
RUN chmod 755 /var/www