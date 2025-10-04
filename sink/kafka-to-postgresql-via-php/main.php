<?php

include __DIR__ . '/vendor/autoload.php';

$conf = new RdKafka\Conf();
$conf->set('metadata.broker.list', '127.0.0.1:9092');
$conf->set('group.id', 'kafka-to-postgresql-via-php');
$conf->set('auto.offset.reset', 'earliest');
$conf->set('enable.partition.eof', 'true');

$consumer = new RdKafka\KafkaConsumer($conf);
//$consumer->subscribe(['127_0_0_1.sakila.country']);
$consumer->subscribe([
    '^127_0_0_1.sakila..*'
    ]);

$db = \DoKafkaMessage\DataAccess::getInstance();

/**
 * Keep track of deletes to treat tombstones
 */
$possibleTombStones = [];

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

            if ((strlen($message->payload) == 0) && (count($possibleTombStones) > 0)) {   // possible tombstone
                if (in_array($message->key, $possibleTombStones)) {
                    $k = array_search($message->key, $possibleTombStones);
                    if ($k !== false) {
                        unset($possibleTombStones[$k]);
                    }
                    error_log(sprintf('This %s is a tombstone. Ignoring.', $message->key));
                    break;
                }
                else {
                    error_log('Message payload is empty - and it is not a tombstone?');
                }
            }
            else {
                if ($jsonPayload['op'] === 'd') {
                    $possibleTombStones[] = $message->key;
                }
            }

            $action = new DoKafkaMessage\ActOnKafkaMessage($jsonKey, $jsonPayload);

            break;
        case RD_KAFKA_RESP_ERR__PARTITION_EOF:
            echo "No more messages; waiting for more...\n";
            sleep(1);
            break;
        case RD_KAFKA_RESP_ERR__TIMED_OUT:
            echo "Timed out\n";
            break;
        default:
            throw new \Exception($message->errstr(), $message->err);
    }
}
