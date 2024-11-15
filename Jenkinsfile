pipeline {
    agent any
    stages {
        stage("Deployment") {
            scp -r "/home/ubuntu/VS Code/cloud/" server@deployment.com:/home/server/Desktop/
            ssh server@deployment.com
        }
        stage("Necessary building blocks") {
            docker network create --subnet=172.20.0.0/16 cloudnet
            docker pull postgres
            docker pull ubuntu:18.04
            docker pull zookeeper:3.4
            docker pull ches/kafka
        }
        stage("Building Kafka") {
            steps {
                echo "Building Kafka..."
                docker run -d --rm --hostname zookeepernode --net cloudnet --ip 172.20.1.3 --name cloud_zookeeper --publish 2181:2181 zookeeper:3.4
                docker run -d --rm --hostname kafkanode --net cloudnet --ip 172.20.1.4 --name cloud_kafka --publish 9092:9092 --publish 7203:7203 --env KAFKA_AUTO_CREATE_TOPICS_ENABLE=true --env KAFKA_ADVERTISED_HOST_NAME=127.0.0.1 --env ZOOKEEPER_IP=172.20.1.3 ches/kafka
                echo "Done!"
            }
        }
        stage("Building Streaming cluster") {
            steps {
                echo "Building Hadoop, Spark and Hive..."
                cd hadoop_spark_cluster_image
                bash 1_create_hadoop_spark_image.sh
                bash 2_create_hadoop_spark_cluster.sh create
                cd ..
                echo "Done!"
            }
        }
        stage("Configuring PostgreSQL") {
            steps {
                echo "Creation of database schema..."
                docker exec -it postgresqlnode bash
                psql -U postgres
                CREATE USER demouser WITH PASSWORD 'demouser';
                ALTER USER demouser WITH SUPERUSER;
                CREATE DATABASE event_message_db;
                GRANT ALL PRIVILEGES ON DATABASE event_message_db TO demouser;
                \c event_message_db;
                \d
                exit
                exit
                echo "Done!"
            }
        }
        stage("Dashboard setup") {
            steps {
                echo "Creating Django dashboard..."
                cd server_status_monitoring
                python manage.py makemigrations dashboard
                python manage.py migrate dashboard
                python managa.py runserver
                cd ..
                echo "Done!"
            }
        }
        stage("Streaming Pipeline") {
            steps {
                echo "Starting the streaming pipeline..."
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
                cd ..
                docker exec -it masternode bash
                cd /opt/workarea/code/
                spark-submit --master local[*] --jars /opt/workarea/spark_jars/commons-pool2-2.8.1.jar,/opt/workarea/spark_jars/postgresql-42.2.16.jar,/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar,/opt/workarea/spark_jars/kafka-clients-2.6.0.jar,/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar --conf spark.executor.extraClassPath=/opt/workarea/spark_jars/commons-pool2-2.8.1.jar:/opt/workarea/spark_jars/postgresql-42.2.16.jar:/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar:/opt/workarea/spark_jars/kafka-clients-2.6.0.jar:/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar --conf spark.executor.extraLibrary=/opt/workarea/spark_jars/commons-pool2-2.8.1.jar:/opt/workarea/spark_jars/postgresql-42.2.16.jar:/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar:/opt/workarea/spark_jars/kafka-clients-2.6.0.jar:/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar --conf spark.driver.extraClassPath=/opt/workarea/spark_jars/commons-pool2-2.8.1.jar:/opt/workarea/spark_jars/postgresql-42.2.16.jar:/opt/workarea/spark_jars/spark-sql-kafka-0-10_2.12-3.0.1.jar:/opt/workarea/spark_jars/kafka-clients-2.6.0.jar:/opt/workarea/spark_jars/spark-streaming-kafka-0-10-assembly_2.12-3.0.1.jar real_time_streaming_data_pipeline.py
                echo "Done!"
            }
        }
    }
}