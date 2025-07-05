<?php

namespace DoKafkaMessage;

class ActOnKafkaMessage
{
    private array $tablePk;
    private ?array $beforeRow;
    private ?array $afterRow;

    private string $tableName;

    private string $operation;
    private array $implementedOperations = ['r', 'c', 'u', 'd', 't'];

    public function __construct($pk, $payload)
    {
        $this->tablePk = $pk;
        $this->beforeRow = $payload['before'];
        $this->afterRow = $payload['after'];

        $this->tableName = $payload['source']['table'];

        $this->operation = $payload['op'];
        if (!in_array($this->operation, $this->implementedOperations)) {
            error_log('Kafka/Debezium operation "' . $this->operation . '" not implemented');
            return;
        }

        switch ($this->operation) {
            case 'r':
                $this->operationSnaphot();
                break;
            case 'c':
                $this->operationCreate();
                break;
            case 'u':
                $this->operationUpdate();
                break;
            case 'd':
                $this->operationDelete();
                break;
            case 't':
                $this->operationTruncate();
                break;
        }
    }

    private function operationSnaphot() {
    }

    private function operationCreate(): void
    {
        $db = \DoKafkaMessage\DataAccess::getInstance();

        $tableColumnsNames = [];
        $tableColumnsBinders = [];
        $tableColumnsValues = [];
        foreach ($this->afterRow as $pki => $pkv) {
            $tableColumnsNames[] = $pki;
            $tableColumnsBinders[] = ':col_' . $pki;
            $tableColumnsValues[] = $pkv;
        }

        $preparedInsert = $db->PDO->prepare(
        'INSERT INTO ' . $this->tableName . ' ('
            . implode(', ', $tableColumnsNames) . ') VALUES('
            . implode(', ', $tableColumnsBinders) . ')'
        );
        foreach ($tableColumnsBinders as $bi => $bv) {
            $preparedInsert->bindValue($bv, $tableColumnsValues[$bi]);
        }
        $preparedInsert->execute();
    }

    private function operationUpdate(): void
    {
        foreach ($this->beforeRow as $bi => $bv) {
            if ($bv == $this->afterRow[$bi]) {
                unset($this->afterRow[$bi]);
            }
        }

        $updateColumnsNames = [];
        $updateColumnsWithBinders = [];
        $updateValues = [];
        foreach ($this->afterRow as $ai => $av) {
            $updateColumnsNames[] = $ai;
            $updateColumnsWithBinders[] = $ai . ' = :col_' . $ai;
            $updateValues[] = $av;
        }

        $whereClause = $this->prepareWhereClause();

        $db = \DoKafkaMessage\DataAccess::getInstance();
        // UPDATE tableName SET a = :a, b = :b WHERE x1 = :x1 AND x2 = :x2
        $sql = 'UPDATE ' . $this->tableName . ' SET ' . implode(', ', $updateColumnsWithBinders) . ' WHERE ' . implode(' AND ', $whereClause['columns']);
        error_log('SQL: ' . $sql);

        $preparedUpdate = $db->PDO->prepare($sql);
        foreach ($updateColumnsNames as $ai => $av) {
            $preparedUpdate->bindValue(':col_' . $av, $updateValues[$ai]);
        }

        foreach ($whereClause['columnsWithBinders'] as $wci => $wcv) {
            $preparedUpdate->bindValue(':col_' . $wcv, $whereClause['values'][$wci]);
        }

        $preparedUpdate->execute();
    }

    private function operationDelete() {
        $whereClause = $this->prepareWhereClause();

        $db = \DoKafkaMessage\DataAccess::getInstance();
        // DELETE FROM tableName WHERE x1 = :x1 AND x2 = :x2
        $sql = 'DELETE FROM ' . $this->tableName . ' WHERE ' . implode(' AND ', $whereClause['columns']);
        error_log('SQL: ' . $sql);

        $preparedDelete = $db->PDO->prepare($sql);
        foreach ($whereClause['columnsWithBinders'] as $wci => $wcv) {
            $preparedDelete->bindValue(':col_' . $wcv, $whereClause['values'][$wci]);
        }

        $preparedDelete->execute();
    }

    private function operationTruncate() {
    }

    private function prepareWhereClause() {
        $whereClause = [
            'columns'               => [],
            'columnsWithBinders'    => [],
            'values'                => []
        ];

        foreach ($this->tablePk as $pki => $pkv) {
            $whereClause['columns'][] = $pki . ' = :col_' . $pki;
            $whereClause['columnsWithBinders'][] = $pki;
            $whereClause['values'][] = $pkv;
        }

        return $whereClause;
    }

}
