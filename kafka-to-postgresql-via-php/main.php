<?php

include __DIR__ . '/vendor/autoload.php';

$conf = new RdKafka\Conf();
$conf->set('metadata.broker.list', '127.0.0.1:9092');
$conf->set('group.id', 'kafka-to-postgresql-via-php');
$conf->set('auto.offset.reset', 'earliest');
$conf->set('enable.partition.eof', 'true');

$consumer = new RdKafka\KafkaConsumer($conf);
$consumer->subscribe([
    '127_0_0_1.sakila.country',
    '127_0_0_1.sakila.film_actor'
    ]);

$db = \DoKafkaMessage\DataAccess::getInstance();

while (true) {
    $message = $consumer->consume(120 * 1000);
    switch ($message->err) {
        case RD_KAFKA_RESP_ERR_NO_ERROR:
            echo "Received message on topic " . $message->topic_name . "@" . $message->timestamp . "\n";
            if (strlen($message->payload) == $message->len) {
                echo "Valid message.\n";
            }
            else {
                echo "Invalid message.\n";
                break;
            }

            $jsonKey = json_decode($message->key, true);
            $jsonPayload = json_decode($message->payload, true);

            var_dump($jsonKey, $jsonPayload);
            $action = new DoKafkaMessage\ActOnKafkaMessage($jsonKey, $jsonPayload);

            break;
        case RD_KAFKA_RESP_ERR__PARTITION_EOF:
            echo "No more messages; will wait for more\n";
            sleep(1);
            break;
        case RD_KAFKA_RESP_ERR__TIMED_OUT:
            echo "Timed out\n";
            break;
        default:
            throw new \Exception($message->errstr(), $message->err);
    }
}
