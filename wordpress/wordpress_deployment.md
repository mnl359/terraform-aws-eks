### Configure workstation kubeconfig

- aws eks --region us-east-1 update-kubeconfig --name eks-wordpress --profile default

### Create Storage Class, Namespace and Secret

- kubectl create -f gp2-storage-class.yaml
- kubectl create namespace wp
- kubectl create secret generic mysql-pass --from-literal=password=insert_your_password_here --namespace=wp
- kubectl create secret generic mysql-pass --from-literal=password=$(aws secretsmanager get-random-password --password-length 20 --no-include-space | jq -r .RandomPassword) --namespace=wp

### Mysql Deployment

- kubectl create -f mysql-deployment.yaml --namespace=wp
- kubectl get pods --namespace=wp

### Wordpress Deployment

- kubectl create -f wordpress-deployment.yaml --namespace=wp
- kubectl get pods --namespace=wp

### Validate Services

- kubectl get storageclass
- kubectl get all --namespace=wp
- kubectl get pods --namespace=wp
- kubectl get svc --namespace=wp
- kubectl get svc -l app=wordpress --namespace=wp -o=jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
- kubectl get deployments --namespace=wp
- kubectl get pvc --namespace=wp
- kubectl get secrets --namespace=wp

### How to connect to MySQL pod 

- kubectl get pods --namespace=wp
- kubectl get secret mysql-pass --namespace=wp -o yaml
- kubectl get secrets/mysql-pass --namespace=wp --template={{.data.password}} | base64 -D
- kubectl exec -it change_pod_name --namespace=wp -- /bin/bash

### How to connect to Wordpress pods

- kubectl get pods --namespace=wp
- kubectl exec -it change_pod_name --namespace=wp -- /bin/bash

### Delete Wordpress Objects

- kubectl delete deployment wordpress --namespace=wp
- kubectl delete deployment wordpress-mysql --namespace=wp
- kubectl delete service wordpress --namespace=wp
- kubectl delete service wordpress-mysql --namespace=wp
- kubectl delete pvc mysql-pv-claim --namespace=wp
- kubectl delete pvc wp-pv-claim --namespace=wp
- kubectl delete secrets mysql-pass --namespace=wp
- kubectl delete namespace wp
- kubectl delete storageclass standard