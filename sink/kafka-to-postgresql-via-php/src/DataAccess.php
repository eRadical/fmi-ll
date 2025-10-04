<?php

namespace DoKafkaMessage;

use Exception;
use DoKafkaMessage\iSingleton;
use PDO;
use PDOException;

class DataAccess implements iSingleton
{
    use SingletonTrait;

    private static mixed $dataAccessInstance;

    /**
     * Database link
     */
    public ?PDO $PDO = null;

    /**
     * Get the instance of the object or construct a new one if necessary
     */
    public static function getInstance(): DataAccess
    {
        if (!isset(self::$dataAccessInstance))
        {
            $c = __CLASS__;
            self::$dataAccessInstance = new $c;
        }
        return self::$dataAccessInstance;
    }

    /**
     * Create DataAccess object one time per request
     *
     * @throws DataAccessException
     */
    private function __construct() {
        $this->doConnect();
    }

    /**
     * This method does the real DB connection
     * @return void
     * @throws DataAccessException
     */
    private function doConnect(): void {
        $config = Config::getInstance();

        try {
            $this->PDO = new PDO($config->DsnString, 'sakila', 'sakila', array(PDO::ATTR_EMULATE_PREPARES	=> false));
            $this->PDO->setAttribute(PDO::ATTR_CASE,                PDO::CASE_NATURAL);
            $this->PDO->setAttribute(PDO::ATTR_ERRMODE,             PDO::ERRMODE_EXCEPTION);
            $this->PDO->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE,  PDO::FETCH_ASSOC);
        }
        catch (PDOException $pe) {
            throw new DataAccessException('Unable to start application.', $pe->getCode());
        }
    }
}
