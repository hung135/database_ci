# Set the base image
FROM ubuntu

# Dockerfile author / maintainer
MAINTAINER HUNG NGUYEN <hung135@hotmail.com>

# Update application repository list and install the Redis server.
RUN apt-get update && apt-get install -y sqitch vim git make virtualenv

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.6``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list
#RUN echo "deb https://download.gocd.org /" | tee /etc/apt/sources.list.d/gocd.list
#RUN curl https://download.gocd.org/GOCD-GPG-KEY.asc | apt-key add -
#RUN apt-get update

#RUN echo "deb https://download.gocd.org /" | tee /etc/apt/sources.list.d/gocd.list
#curl https://download.gocd.org/GOCD-GPG-KEY.asc | sudo apt-key add -
#sudo apt-get update
#RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y openjdk-8-jre apache2-utils

RUN wget https://download.gocd.org/binaries/18.1.0-5937/deb/go-server_18.1.0-5937_all.deb
RUN wget https://download.gocd.org/binaries/18.1.0-5937/deb/go-agent_18.1.0-5937_all.deb
RUN cat /etc/apt/sources.list.d/pgdg.list
#RUN cat /etc/apt/sources.list.d/gocd.list
RUN curl https://download.gocd.org/GOCD-GPG-KEY.asc | apt-key add -
RUN echo "deb https://download.gocd.org /" > /etc/apt/sources.list.d/gocd.list

#RUN apt-key list
#RUN apt-get update && apt-get install -y sqitch vim git make curl wget
#RUN dpkg -i go-server_18.1.0-5937_all.deb
RUN apt-get update
RUN apt-get install default-jre go-server go-agent apache2-utils
RUN chown -R go:go /mnt/artifact-storage
RUN htpasswd -B -c /etc/go/authentication sammy
RUN htpasswd -B /etc/go/authentication admin
RUN systemctl start go-server go-agent

# Install ``python-software-properties``, ``software-properties-common`` and PostgreSQL 9.6
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6

# Note: The official Debian and Ubuntu images automatically ``apt-get clean``
# after each ``apt-get``

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.6`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.6/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.6/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.6/bin/postgres", "-D", "/var/lib/postgresql/9.6/main", "-c", "config_file=/etc/postgresql/9.6/main/postgresql.conf"]
# Expose default port
#/usr/lib/postgresql/9.6/bin/postgres -D /var/lib/postgresql/9.6/main -c config_file=/etc/postgresql/9.6/main/postgresql.conf
#EXPOSE 22

# Set the default command
#ENTRYPOINT ["/usr/bin/redis-server"]

#ENTRYPOINT ["/bin/bash"]