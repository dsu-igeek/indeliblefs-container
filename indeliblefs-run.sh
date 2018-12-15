#!/bin/sh
docker rm indeliblefs
#docker run -d -v /data/dbserver-psql:/var/lib/pgsql --name dbserver --log-driver=syslog --restart unless-stopped dbserver
docker run -d --name indeliblefs --log-driver=syslog --restart unless-stopped indeliblefs
