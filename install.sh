#!/bin/bash
# Install script for setting up two postgres dbs using docker
# This script need execution rights

# create docker volume folders
sudo mkdir -p /var/docker_volumes

# set permissions for folders (maybe use whomami to get the current user)
sudo chown $(whoami) /var/docker_volumes
sudo chgrp $(whoami) /var/docker_volumes

# create test network
docker network create test

set -e

# Use of the filename flag is not necessary, but maybe we want to change the name of the file in the future
docker-compose -f docker-compose.yml up -d

# setup replication
psql -h localhost -p 15432 -U postgres -c "CREATE USER replicator with REPLICATION ENCRYPTED PASSWORD 'password';"
psql -h localhost -p 15432 -U postgres -c "alter system set wal_level = replica ;"
psql -h localhost -p 15432 -U postgres -c "alter system set max_wal_senders = 10 ;"
psql -h localhost -p 15432 -U postgres -c "alter system set hot_standby = on ;"
docker exec -it master-db /bin/bash -c "echo 'host replication replicator 0.0.0.0/0 trust'>>/var/lib/postgresql/data/pg_hba.conf"

docker-compose restart master-db

docker exec -it master-db /bin/bash -c 'mkdir /tmp/postgres_replica'
docker exec -it master-db /bin/bash -c 'pg_basebackup -h localhost -U replicator -p 5432 -D /tmp/postgres_replica -Fp -Xs -P -Rv'

docker cp master-db:/tmp/postgres_replica . 

docker-compose stop replica-db

sudo cp postgres_replica /var/docker_volumes/ -R

docker-compose start replica-db

sleep 5

psql -h localhost -p 15433 -U postgres -c "alter system set primary_conninfo='host=master-db user=replicator port=5432';"

docker-compose restart replica-db

# Setup test db on both instances 
# (It is unclear if the default postgres db should be rename test, or if a new db that should be used by default should be created)
psql -h 127.0.0.1 -p 15432 -U postgres -f create_db.sql

rm postgres_replica -R


