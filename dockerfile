FROM centos-6-epel
MAINTAINER "dave" <dave@igeekinc.com>
ENV container docker

RUN yum install -y supervisor openssh-server postgresql-server

RUN /usr/bin/ssh-keygen -f /root/.ssh/id_rsa

COPY overrides/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir /etc/postgresql
COPY overrides/etc/postgresql/postgresql.conf /etc/postgresql/postgresql.conf
COPY overrides/etc/postgresql/pg_hba.conf /etc/postgresql/pg_hba.conf
COPY overrides/etc/postgresql/pg_ident.conf /etc/postgresql/pg_ident.conf
RUN chown -R postgres /etc/postgresql

RUN yum install -y http://jenkins.igeekinc.com:8080/job/IndelibleBuilds/job/IndelibleFSGitHubCentos/lastSuccessfulBuild/artifact/IndelibleFS-Linux/output/rpmbuild/RPMS/x86_64/indelible-fs-0.1.0-10557.x86_64.rpm

RUN mkdir -p /data/cas01
RUN mkdir -p /var/lib/pgsql/data
RUN chown -R postgres /var/lib/pgsql/data

USER postgres
RUN export PGDATA=/var/lib/pgsql/data; /usr/bin/initdb --encoding=UTF8
USER root

RUN /etc/init.d/postgresql start && \
export SERVERPORT=50901 AUTHSERVERPORT=50902 FSDBUSER=indelible FSDBPASS=indelible \
FSDBNAME=indeliblefs CASSTOREPATH=/data/cas01 ROOTAUTHENTICATIONSERVER="" \
CLIENTAUTHENTICATIONSERVER=localhost:50902;/usr/share/igeek/indelible-fs/bin/indelible-fs-setup
EXPOSE 22
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
