#!/bin/bash

cd mongodb/

# I assume the cluster authentication is ready

TMPFILE=$(mktemp)

kubectl --v=0 apply -f namespace.yaml
kubectl --v=0 apply -f mongodb-storageclass-ssd-aws.yaml

if [ -x "$(command -v openssl)" ]; then
    openssl rand -base64 741 > $TMPFILE
    kubectl --v=0 --namespace=stage create secret generic shared-bootstrap-data --from-file=internal-auth-mongodb-keyfile=$TMPFILE
    rm $TMPFILE
else
    echo "Please install OpenSSL"
    exit 1
fi

kubectl --v=0 apply -f mongodb-configdb-service-stateful.yaml

sleep 1m

for i in 0 1 2
do
    until kubectl --v=0 exec --namespace=stage mongodb-configdb-$i -c mongodb-configdb-container -- mongo --port 27019 --quiet --eval 'db.getMongo()'; do
        echo -n "mongodb-configdb-$i: "
    done
done

# Replica Set Configuration
kubectl --v=0 exec --namespace=stage mongodb-configdb-0 -c mongodb-configdb-container -- mongo --port 27019 --quiet --eval "rs.initiate({ 
    _id: \"ReplSetConfig\", 
    version: 1, members: [ 
            { _id: 0, host: \"mongodb-configdb-0.mongodb-configdb-service.stage.svc.cluster.local:27019\" },
            { _id: 1, host: \"mongodb-configdb-1.mongodb-configdb-service.stage.svc.cluster.local:27019\" },
            { _id: 2, host: \"mongodb-configdb-2.mongodb-configdb-service.stage.svc.cluster.local:27019\" }
        ]
    });"

kubectl --v=0 exec --namespace=stage mongodb-configdb-0 -c mongodb-configdb-container -- mongo --port 27019 --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
kubectl --v=0 exec --namespace=stage mongodb-configdb-0 -c mongodb-configdb-container -- mongo --port 27019 --quiet --eval 'rs.status();'

#### Sharded Cluster
kubectl --v=0 apply -f mongodb-sharded-service-stateful.yaml

## TODO: - wait a minute
sleep 1m

for i in 0 1 2
do
    until kubectl --v=0 exec --namespace=stage mongodb-sharded-$i -c mongodb-sharded-container -- mongo --port 27017 --quiet --eval 'db.getMongo()'; do
        echo -n "mongodb-sharded-$i: "
    done
done

kubectl --v=0 exec --namespace=stage mongodb-sharded-0 -c mongodb-sharded-container -- mongo --port 27017 --quiet --eval "rs.initiate({ 
    _id: \"ReplSetSharded\",
    version: 1, members: [ 
            { _id: 0, host: \"mongodb-sharded-0.mongodb-sharded-service.stage.svc.cluster.local:27017\"},
            { _id: 1, host: \"mongodb-sharded-1.mongodb-sharded-service.stage.svc.cluster.local:27017\"},
            { _id: 2, host: \"mongodb-sharded-2.mongodb-sharded-service.stage.svc.cluster.local:27017\"}
        ]
    });"

kubectl --v=0 exec --namespace=stage mongodb-sharded-0 -c mongodb-sharded-container -- mongo --port 27017 --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'

kubectl --v=0 exec --namespace=stage mongodb-sharded-0 -c mongodb-sharded-container -- mongo --port 27017 --quiet --eval 'db.getSiblingDB("admin").createUser({ user:"'"admin"'", pwd:"'"a1s2d3f4"'", roles: [{ role: "userAdminAnyDatabase", db: "admin" }, { "role" : "clusterAdmin", "db" : "admin" }] });'

kubectl --v=0 exec --namespace=stage mongodb-sharded-0 -c mongodb-sharded-container -- mongo -u admin -p a1s2d3f4 --authenticationDatabase admin --port 27017 --quiet --eval 'rs.status();'

kubectl --v=0 apply -f mongodb-mongos-service-stateful.yaml

for i in 0
do
    until kubectl --v=0 exec --namespace=stage mongos-router-$i -c mongos-container -- mongo --port 27017 --quiet --eval 'db.getMongo()'; do
        echo -n ""
    done
done

# Create admin user
kubectl --v=0 exec --namespace=stage $(kubectl get pod -l "tier=routers" -o jsonpath='{.items[0].metadata.name}' --namespace=stage) -c mongos-container -- mongo --port 27017 --quiet --eval 'db.getSiblingDB("admin").createUser({ user:"'"admin"'", pwd:"'"a1s2d3f4"'", roles: [{ role: "userAdminAnyDatabase", db: "admin" }, { "role" : "clusterAdmin", "db" : "admin" }] });'

# Adding Express Cart user to MongoDB
kubectl --v=0 exec --namespace=stage $(kubectl get pod -l "tier=routers" -o jsonpath='{.items[0].metadata.name}' --namespace=stage) -c mongos-container -- mongo --port 27017 --quiet --eval 'db.getSiblingDB("admin").auth("admin", "a1s2d3f4"); db.getSiblingDB("expresscart").createUser({ user:"'"adminec"'", pwd:"'"a1s2d3f4"'", roles: [{ role: "dbOwner", db: "expresscart" }] });'

kubectl --v=0 exec --namespace=stage $(kubectl get pod -l "tier=routers" -o jsonpath='{.items[0].metadata.name}' --namespace=stage) -c mongos-container -- mongo -u admin -p a1s2d3f4 --authenticationDatabase admin --port 27017 --quiet --eval 'sh.addShard("ReplSetSharded/mongodb-sharded-0.mongodb-sharded-service.stage.svc.cluster.local:27017,mongodb-sharded-1.mongodb-sharded-service.stage.svc.cluster.local:27017,mongodb-sharded-2.mongodb-sharded-service.stage.svc.cluster.local:27017");'

kubectl --v=0 exec --namespace=stage $(kubectl get pod -l "tier=routers" -o jsonpath='{.items[0].metadata.name}' --namespace=stage) -c mongos-container -- mongo -u admin -p a1s2d3f4 --authenticationDatabase admin --port 27017 --quiet --eval 'sh.status()'

kubectl --v=0 apply -f mongodb-mongos-service-load-balancer-aws.yaml

kubectl --v=0 --namespace=stage get all