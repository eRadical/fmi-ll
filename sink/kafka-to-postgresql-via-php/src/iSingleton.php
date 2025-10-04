<?php

namespace DoKafkaMessage;
use Exception;

/**
 * e-radical
 *
 * iSingleton - An interface for all singletons
 *
 * @copyright  Gabriel PREDA
 */
interface iSingleton
{

    /**
     * This Method must be implemented by all classes that implement this interface
     *
     * @static
     * @access public
     */
    static function getInstance(): iSingleton;

    /**
     * This Method must be implemented by all classes that implement this interface
     *
     * @return void
     * @throws Exception
     * @abstract
     * @access public
     */
    function __clone();

}
