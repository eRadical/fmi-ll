<?php
/**
 * e-radical
 *
 * This class contains config object support
 *
 * @author Gabriel PREDA
 */

namespace DoKafkaMessage;

use Exception;
use Throwable;

final class Config implements iSingleton {

use SingletonTrait;

private int $versionMajor = 0;
private int $versionMinor = 1;
private int $versionPatch = 0;

private static mixed $configInstance;

protected string $DsnString = 'pgsql:host=localhost;port=5432;dbname=sakila;user=sakila;password=sakila';

protected string $kafkaTopicPrefix = '';
protected string $kafkaTopics = '';

/**
 * Get the instance of the object or construct a new one if necessary
 */
public static function getInstance(): Config
{
	if (!isset(self::$configInstance))
	{
		$c = __CLASS__;
		self::$configInstance = new $c;
	}
	return self::$configInstance;
}

/**
 * @throws Exception
 */
private function __construct()
{
    $this->loadConfig();
}

/**
 * @return void
 * @throws Exception
 */
private function loadConfig(): void {
    $filePath = file_get_contents(dirname(dirname(__DIR__)) . '/register-mariadb.json');
    $configFile = json_decode($filePath, true);
    $configFile = $configFile['config'];
    $this->kafkaTopicPrefix = $configFile['topic.prefix'];
    $this->kafkaTopics = $configFile['database.include.list'];
}

/**
 * Magic getter
 */
public function __get(string $property): mixed
{
	if ('version' == $property)
	{
		return $this->getVersion();
	}

	if ('serverName' == $property)
	{
		return $_SERVER['SERVER_NAME'];
	}

	return $this->$property;
}

/**
 * Get application version
 */
private function getVersion(): string
{
	return $this->versionMajor
		. str_pad($this->versionMinor, 2, '0', STR_PAD_LEFT)
		. str_pad($this->versionPatch, 2, '0', STR_PAD_LEFT);
}


}

/**
 * Set a general exception handler for uncaught unrecoverable Exceptions
 */
set_exception_handler(function (Throwable $exception) {
    echo "<p>We have encountered an error. Rest assured we are already working on a fix.</p>",
    "<pre style='display: none'>",
    print_r($exception, true),
    "</pre>";
});
