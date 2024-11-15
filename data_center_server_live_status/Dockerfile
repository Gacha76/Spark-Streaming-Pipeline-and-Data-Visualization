FROM ches/kafka

WORKDIR /app

EXPOSE 9092
EXPOSE 7203

ADD data_center_server_live_status_simulator.py /app/data_center_server_live_status_simulator.py
ADD kafka_consumer.py /app/kafka_consumer.py
ADD requirements.txt /app/requirements.txt

ENV KAFKA_AUTO_CREATE_TOPICS_ENABLE true
ENV KAFKA_ADVERTISED_HOST_NAME 127.0.0.1
ENV ZOOKEEPER_IP 172.20.1.3

RUN pip install requirements.txt

CMD ["python", "data_center_server_live_status_simulator.py"]
