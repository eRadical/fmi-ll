
# Start MariaDB connector
curl -i -X POST \
    -H "Accept:application/json" \
    -H  "Content-Type:application/json" \
    http://127.0.0.1:8083/connectors/ -d @register-mariadb.json

Response:

HTTP/1.1 201 Created
Server: Jetty(12.0.15)
Date: Sun, 22 Jun 2025 17:00:03 GMT
Location: http://127.0.0.1:8083/connectors/inventory-connector
Content-Type: application/json
Content-Length: 510

{"name":"inventory-connector","config":{"connector.class":"io.debezium.connector.mariadb.MariaDbConnector","tasks.max":"1","database.hostname":"127.0.0.1","database.port":"3306","database.user":"employees","database.password":"employees","database.server.id":"6546416","topic.prefix":"mdb-","database.include.list":"employees","schema.history.internal.kafka.bootstrap.servers":"127.0.0.1:9092","schema.history.internal.kafka.topic":"mdb-schema-changes","name":"inventory-connector"},"tasks":[],"type":"source"}




"topic.creation.default.delete.retention.ms": "604800000" /* 7 × 24 × 3600 × 1000 */



# Delete MariaDB connector
curl -i -X DELETE \
-H "Accept:application/json" \
-H  "Content-Type:application/json" \
http://127.0.0.1:8083/connectors/inventory-connector


{
    "name": "inventory-connector",
    "config": {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "tasks.max": "1",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "false",
        "database.hostname": "postgres",
        "database.port": "5432",
        "database.user": "postgres",
        "database.password": "postgres",
        "database.dbname" : "postgres",
        "database.server.name": "dbserver1",
        "schema.include": "inventory"
        }
}