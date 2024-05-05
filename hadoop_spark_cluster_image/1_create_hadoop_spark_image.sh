#!/bin/bash

# generate ssh key
echo "Y" | ssh-keygen -t rsa -P "" -f configs/id_rsa

# Building Hadoop Docker Image
docker build -f ./cloud_hadoop/Dockerfile . -t hadoop_spark_cluster:cloud_hadoop

# Building Spark Docker Image
docker build -f ./cloud_spark/Dockerfile . -t hadoop_spark_cluster:cloud_spark

# Building PostgreSQL Docker Image for Hive Metastore Server
docker build -f ./cloud_postgresql/Dockerfile . -t hadoop_spark_cluster:cloud_postgresql

# Building Hive Docker Image
docker build -f ./cloud_hive/Dockerfile . -t hadoop_spark_cluster:cloud_hive

