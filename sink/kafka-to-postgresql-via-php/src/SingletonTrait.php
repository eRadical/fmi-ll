<?php

namespace DoKafkaMessage;

use Exception;

trait SingletonTrait
{
    abstract protected function __construct();

    /**
     * @throws Exception
     */
    public function __clone() {
        throw new Exception('Cannot clone a singleton.');
    }

    /**
     * Throw Exception when trying to use __wakeup
     * @throws Exception
     */
    public function __wakeup() {
        throw new Exception('Cannot unserialize a singleton.');
    }
}
