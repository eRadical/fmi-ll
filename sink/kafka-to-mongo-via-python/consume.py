#!/usr/bin/python

from kafka import KafkaConsumer
import signal, sys, json
from act_on_kafka_message import ActOnKafkaMessage
from pymongo import MongoClient
import logging

def signal_handler(sig, frame):
    mongoClient.close()
    print('Exiting because pressed Ctrl+C!')
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

try:
    consumer = KafkaConsumer(
        group_id='kafka-to-mongo-via-python',
        bootstrap_servers=['127.0.0.1:9092'],
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        key_deserializer=lambda k: k if k is None else k.decode('utf-8')
    )
    consumer.subscribe(pattern='^127_0_0_1.sakila..*')

    mongoClient = MongoClient(host="localhost", port=27017, connect=True, connectTimeoutMS=2000, serverSelectionTimeoutMS=2000)
    mongoClient.admin.command('ping')
    mongoDB = mongoClient.sakila

except Exception as e:
    print(f"Failed to connect to database or Kafka: {e}")
    exit(6)

possible_tomb_stones = []

for message in consumer:
    print("%s:%d:%d: key=%s value=%s value_size=%d" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value, message.serialized_value_size))
    if message.value is None and message.serialized_value_size == -1:
        if message.key in possible_tomb_stones:
            i = possible_tomb_stones.index(message.key)
            possible_tomb_stones.pop(i)
            print("This %s is a TombStone. Ignoring.\n" % message.key)
            continue
        else:
            print('Message payload is empty - and it is not a tombstone?')
            continue

    if len(message.value.decode('utf-8')) != message.serialized_value_size:
        print("Invalid message.\n")
        continue

    json_key = None if message.key is None else json.loads(message.key)
    json_payload = json.loads(message.value.decode('utf-8'))

    if json_payload['op'] == 'd':
        possible_tomb_stones.append(message.key)

    ActOnKafkaMessage(json_key, json_payload, mongoDB)
