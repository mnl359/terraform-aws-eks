#!/bin/bash

cd mongodb/

kubectl delete -f mongodb-mongos-service-load-balancer-aws.yaml
kubectl delete -f mongodb-mongos-service-stateful.yaml
kubectl delete -f mongodb-sharded-service-stateful.yaml
kubectl delete -f mongodb-configdb-service-stateful.yaml
kubectl delete -f mongodb-storageclass-ssd-aws.yaml
kubectl delete -f namespace.yaml