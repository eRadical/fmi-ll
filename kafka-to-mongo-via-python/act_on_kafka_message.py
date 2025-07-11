import logging
import hashlib
import json

class ActOnKafkaMessage:
    implementedOperations = ['r', 'c', 'u', 'd', 't']

    def __init__(self, pk, payload, mongo_db):
        self.mongoDB = mongo_db

        self.pk = pk
        if self.pk is not None:
            self.pkHash = hashlib.md5(json.dumps(self.pk, sort_keys = True).encode("utf-8")).hexdigest()

        self.beforeRow = payload['before']
        self.afterRow = payload['after']

        self.tableName = payload['source']['table']
        self.mongoCollection = self.mongoDB[self.tableName]
        self.op = payload['op']
        if self.op not in self.implementedOperations:
            logging.error('Kafka/Debezium operation "' + self.op + '" not implemented')
            return

        match self.op:
            case 'r':
                self.operation_snaphot()
            case 'c':
                self.operation_create()
            case 'u':
                self.operation_update()
            case 'd':
                self.operation_delete()
            case 't':
                self.operation_truncate()

    def operation_snaphot(self):
        find_if_exists = self.mongoCollection.find_one({'_id' : self.pkHash})
        if find_if_exists is None:
            self.operation_create()
            return

        for key, value in self.afterRow.items():
            if value == self.afterRow[key]:
                del self.afterRow[key]

        update_diffs = self.mongoCollection.update_one({'_id' : self.pkHash}, {'$set' : self.afterRow})

        logging.info('operationSnapshot: %s count: %d' % (self.pkHash, update_diffs.matched_count))
        return

    def operation_create(self):
        self.afterRow['_id'] = self.pkHash

        new_data = self.mongoCollection.insert_one(self.afterRow)

        logging.info('operationCreate: %s ' % new_data)
        return

    def operation_update(self):
        find_existent = self.mongoCollection.find_one({'_id' : self.pkHash})
        if find_existent is None:
            self.operation_create()
            return

        for key, value in self.beforeRow.items():
            if value == self.afterRow[key]:
                del self.afterRow[key]

        updated_one = self.mongoCollection.update_one({'_id' : self.pkHash}, {'$set' : self.afterRow})

        logging.info('operationUpdate: %s count: %d' % (self.pkHash, updated_one.matched_count))
        return

    def operation_delete(self):
        deleted_one = self.mongoCollection.delete_one({'_id' : self.pkHash})

        logging.info('operationDelete: %s count: %d' % (self.pkHash, deleted_one.deleted_count))
        return

    def operation_truncate(self):
        self.mongoCollection.drop()

        logging.info('operationTruncate: in Mongo is implemented as .drop() for %s' % self.tableName)
        return
