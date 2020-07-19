#!/bin/bash
# Install script for setting up two postgres dbs using docker
# This script need execution rights

# create docker volume folders

# set permissions for folders (maybe use whomami to get the current user)

# Use of the filename flag is not necessary, but maybe we want to change the name of the file in the future
docker-compose -f docker-compose.yml up -d
