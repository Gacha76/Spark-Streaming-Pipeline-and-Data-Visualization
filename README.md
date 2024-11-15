<p align="center">
  <h2 align="center"><i>Real Time Data Analysis of Data servers using Apache Hadoop, Spark and Kafka on Docker</i></h2>
</p>

> Apache Hadoop, Apache Spark, Apache ZooKeeper, Kafka, Scala, Python, PySpark PostgreSQL, Docker, Django, Flexmonster, Real Time Streaming, Data Pipeline, Dashboard

## Table of Contents

- [Introduction](#introduction)
- [Frameworks/Technologies used](#frameworkstechnologies-used)
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
  - [Docker Setup](#a-docker-setup)
  - [Create a Kafka Cluster in Docker](#b-create-a-kafka-cluster-in-docker)
  - [Create an Apache Hadoop and Spark Cluster on Docker](#c-create-an-apache-hadoop-and-spark-cluster-on-docker)
- [Development Setup](#development-setup)
  - [Event Simuator Using Python](#a-event-simuator-using-python)
  - [Setting up PostgreSQL Database (Events Database)](#b-setting-up-postgresql-database-events-database)
  - [Building Streaming Data Pipeline using Python and Spark Structured Streaming (PySpark Based)](#c-building-streaming-data-pipeline-using-python-and-spark-structured-streaming-pyspark-based)
  - [Building Dashboard using Django Web Framework and Flexmonster for Visualization](#d--building-dashboard-using-django-web-framework-and-flexmonster-for-visualization)
- [Final Result](#final-result)
- [Team Members](#team-members)


### Introduction

* In many data centers, different type of servers generate large amounts of data (events, in this case is status of the server in the data center) in real-time.

* There is always a need to process this data in real-time and generate insights which will be used by the Data Server Manager who have to track the server's status regularly and find the resolution in case of issues occurring, for better server stability.

* Since the data is huge and generated in real-time, we need to choose the right architecture with scalable storage and computation frameworks/technologies.

* Hence we want to build the Real Time Data Pipeline Using Apache Kafka, Apache Spark, Hadoop, PostgreSQL, Django and Flexmonster on Docker to generate insights out of this data.

* The Spark Project/Data Pipeline is built using Apache Spark with Python and PySpark on an Apache Hadoop Cluster running on top of Docker.

* Data Visualization is built using Django Web Framework and Flexmonster.

### Use Case Diagram
![use case](https://github.com/DataScience-ArtificialIntelligence/Spark-Streaming-Pipeline-and-Data-Visualization/assets/114498897/e8da9a3a-74d5-49d0-a6c0-fd61485ccf61)


### Frameworks/Technologies used

* Apache Hadoop
* Apache Spark
* Apache ZooKeeper
* Docker
* Kafka
* Django
* Flexmonster
* Python
* PySpark

### Prerequisites

- asgiref==3.8.1
- certifi==2024.2.2
- charset-normalizer==3.3.2
- Django==5.0.4
- idna==3.7
- kafka-python==2.0.2
- psycopg2-binary==2.9.9
- py4j==0.10.9
- pyspark==3.0.1
- python-restcountries==2.0.0
- requests==2.31.0
- sqlparse==0.5.0
- typing_extensions==4.11.0
- urllib3==2.2.1
- Python==3.10


### Environment Setup

**Note:** Download `apache-hive-2.3.7-bin.tar.gz`, `hadoop-3.2.1.tar.gz` and `spark-3.0.1-bin-hadoop3.2.tgz` and keep them in `cloud_hive`, `cloud_hadoop` and `cloud_spark` folders containing the Dockerfiles respectively before proceeding with the setup.

#### (a) Docker Setup
Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Windows\Linux Operating System.

**Note:** If you are installing on Windows, make sure the system requirements are met and `WSL2` is enabled to run the `Docker Engine`.


#### (b) Create a Kafka Cluster in Docker

|     Steps    |                         Type Commands in Terminal                        |
| :--------------------: | :----------------------------------------------------------: |
| 1. Create Docker Network | docker network create --subnet=172.20.0.0/16 cloudnet |
| 2. Create ZooKeeper Container  | docker pull zookeeper:3.4 |
|  | docker run -d --rm --hostname zookeepernode --net cloudnet --ip 172.20.1.3 --name cloud_zookeeper --publish 2181:2181 zookeeper:3.4 |
|     3. Create Kafka Container    | docker pull ches/kafka |
|     | docker run -d --rm --hostname kafkanode --net cloudnet --ip 172.20.1.4 --name cloud_kafka --publish 9092:9092 --publish 7203:7203 --env KAFKA_AUTO_CREATE_TOPICS_ENABLE=true --env KAFKA_ADVERTISED_HOST_NAME=127.0.0.1 --env ZOOKEEPER_IP=172.20.1.3 ches/kafka |


#### (C) Create an Apache Hadoop and Spark Cluster on Docker

|     Steps    |                         Type Commands in Terminal                        |
| :--------------------: | :----------------------------------------------------------: |
| 1. Create docker images for Apache Hadoop, Apache Spark, Apache Hive and PostgreSQL | cd hadoop_spark_cluster_image |
|  | bash 1_create_hadoop_spark_image.sh |
| 2. Create docker containers for Apache Hadoop, Apache Spark, Apache Hive and PostgreSQL    | bash 2_create_hadoop_spark_cluster.sh create |


### Development Setup

#### (a) Event Simuator Using Python
Run the python script "data_center_server_status_simulator.py". This script simulates live creation of server status information.


#### (b) Setting up PostgreSQL Database (Events Database)
```terminal
docker exec -it postgresqlnode bash

psql -U postgres

CREATE USER demouser WITH PASSWORD 'demouser';

ALTER USER demouser WITH SUPERUSER;

CREATE DATABASE event_message_db;

GRANT ALL PRIVILEGES ON DATABASE event_message_db TO demouser;

\c event_message_db;
```


#### (c) Building Streaming Data Pipeline using Python and Spark Structured Streaming (PySpark Based) 

```terminal
docker exec -it masternode bash

mkdir -p /opt/workarea/code

mkdir -p /opt/workarea/spark_jars

exit

cd real_time_data_pipeline

docker cp real_time_streaming_data_pipeline.py masternode:/opt/workarea/code/

cd ../spark_dependency_jars

docker cp commons-pool2-2.8.1.jar masternode:/opt/workarea/spark_jars

docker cp kafka-clients-2.6.0.jar masternode:/opt/workarea/spark_jars

docker cp postgresql-42.2.16.jar masternode:/opt/workarea/spark_jars

docker cp spark-sql-kafka-0-10_2.12-3.0.1.jar masternode:/opt/workarea/spark_jars

docker cp spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar masternode:/opt/workarea/spark_jars

docker exec -it masternode bash

cd /opt/workarea/code/

spark-submit --master local[*] --jars /opt/workarea/spark_jars/commons-pool2-2.8.1.jar,/opt/workarea/spark_jars/postgresql-42.2.16.jar,/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar,/opt/workarea/spark_jars/kafka-clients-2.6.0.jar,/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar --conf spark.executor.extraClassPath=/opt/workarea/spark_jars/commons-pool2-2.8.1.jar:/opt/workarea/spark_jars/postgresql-42.2.16.jar:/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar:/opt/workarea/spark_jars/kafka-clients-2.6.0.jar:/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar --conf spark.executor.extraLibrary=/opt/workarea/spark_jars/commons-pool2-2.8.1.jar:/opt/workarea/spark_jars/postgresql-42.2.16.jar:/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar:/opt/workarea/spark_jars/kafka-clients-2.6.0.jar:/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar --conf spark.driver.extraClassPath=/opt/workarea/spark_jars/commons-pool2-2.8.1.jar:/opt/workarea/spark_jars/postgresql-42.2.16.jar:/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar:/opt/workarea/spark_jars/kafka-clients-2.6.0.jar:/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar real_time_streaming_data_pipeline.py
```


#### (d)  Building Dashboard using Django Web Framework and Flexmonster for Visualization
```terminal
cd server_status_monitoring

python manage.py makemigrations dashboard

python manage.py migrate dashboard

python manage.py runserver
```


### Final Result
The dashboard updates live as the python simultor keeps feeding with new data. Some sample screenshots:

![pie](https://github.com/DataScience-ArtificialIntelligence/Spark-Streaming-Pipeline-and-Data-Visualization/assets/114498897/643632b5-00a7-4c30-999e-c6fbc49055f2)

![bar](https://github.com/DataScience-ArtificialIntelligence/Spark-Streaming-Pipeline-and-Data-Visualization/assets/114498897/d7c84e06-1788-4e36-9414-6bf56828985d)
