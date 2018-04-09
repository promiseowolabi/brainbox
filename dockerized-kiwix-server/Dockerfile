FROM resin/rpi-raspbian
MAINTAINER Promise Owolabi <promise.owolabi@me.com>
RUN apt-get update \
    && apt-get -y install wget bzip2
WORKDIR /kiwix
RUN wget https://download.kiwix.org/bin/kiwix-server-arm.tar.bz2
RUN bzip2 -d kiwix-server-arm.tar.bz2
RUN tar -xvf kiwix-server-arm.tar
VOLUME /kiwix-data
EXPOSE 8080
CMD ["./kiwix-serve","--port","8080","--library","/kiwix-data/data/library/wikipedia_en_all_2016-05.zim.xml"]
