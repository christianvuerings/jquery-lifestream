FROM ubuntu:14.04
MAINTAINER Ben Firshman "ben@orchardup.com"

ENV LANGUAGE en_US.utf8
ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8
ENV PGDATA /var/lib/postgresql/9.3/main
ENV DEBIAN_FRONTEND noninteractive

RUN locale-gen en_US.utf8
RUN apt-get update -y --fix-missing
RUN apt-get install -y --fix-missing -q \
  postgresql-9.3 \
  postgresql-contrib-9.3 \
  sudo

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

# drop and recreate cluster with UTF8 encoding, because Ubuntu Trusty package installs with SQL_ASCII by default.
RUN /usr/bin/pg_dropcluster --stop 9.3 main
RUN /usr/bin/pg_createcluster -e UTF8 9.3 main

# Postgres startup scripts & config
ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

VOLUME ["/var/lib/postgresql"]
EXPOSE 5432
CMD ["/usr/local/bin/run"]

