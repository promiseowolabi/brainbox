FROM resin/rpi-raspbian
 
MAINTAINER Paddy Corr <paddy@corr.co>
 
RUN apt-get update
# RUN apt-get -y upgrade
 
# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN apt-get -y install wget mysql-server apache2-mpm-prefork makepasswd php5 libapache2-mod-php5 libdate-calc-perl libdbd-mysql-perl libdbi-perl libhtml-parser-perl libtiff-tools libwww-mechanize-perl libxml-parser-perl php5-mysql php5-gd php5-xsl php5-curl php5-mcrypt php-soap imagemagick
 
# Enable apache mods.
RUN a2enmod php5
RUN a2enmod rewrite
 
# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini
 
# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
 
EXPOSE 80
 
# Copy site into place.
ADD openemr /var/www/site
 
# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

ENV  APACHE_RUN_USER=www-data \
        APACHE_RUN_GROUP=www-data \
        APACHE_LOG_DIR=/var/log/apache2 \
        APACHE_LOCK_DIR=/var/lock/apache2 \
        APACHE_RUN_DIR=/var/run/apache2 \
        APACHE_PID_FILE=/var/run/apache2.pid 

ADD run-apache.sh /run-apache.sh

RUN chmod -v +x /run-apache.sh \
    && echo ServerName localhost > server.txt \
    && cat server.txt >> /etc/apache2/apache2.conf 
 
# By default, simply start apache.
CMD ["/run-apache.sh"]
