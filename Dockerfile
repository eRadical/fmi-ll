FROM quay.io/debezium/connect
LABEL authors="preda"

RUN mkdir /kafka/connect/connect-file && cp /kafka/libs/connect-file-4.0.0.jar /kafka/connect/connect-file/ && mkdir /tmp/sakila-audit

