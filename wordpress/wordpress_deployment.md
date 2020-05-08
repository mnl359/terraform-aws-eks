### Configure workstation kubeconfig

- aws eks --region us-east-1 update-kubeconfig --name eks-wordpress --profile default

### Create Storage Class, Namespace and Secret

- kubectl create -f gp2-storage-class.yaml
- kubectl create namespace wp
- kubectl create secret generic mysql-pass --from-literal=password=$(aws secretsmanager get-random-password --password-length 20 --no-include-space | jq -r .RandomPassword) --namespace=wp

### Mysql Deployment

- kubectl create -f mysql-deployment.yaml --namespace=wp
- kubectl get pods --namespace=wp
- kubectl create -f wordpress-deployment.yaml --namespace=wp

### Validate Services

- kubectl get all --namespace=wp
- kubectl get pods --namespace=wp
- kubectl get svc --namespace=wp
- kubectl get svc -l app=wordpress --namespace=wp -o=jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
- kubectl get deployments --namespace=wp
- kubectl get pvc --namespace=wp

### Delete Wordpress Objects

- kubectl delete deployment wordpress --namespace=wp
- kubectl delete deployment wordpress-mysql --namespace=wp
- kubectl delete service wordpress --namespace=wp
- kubectl delete service wordpress-mysql --namespace=wp
- kubectl delete pvc mysql-pv-claim --namespace=wp
- kubectl delete pvc wp-pv-claim --namespace=wp
- kubectl delete namespace wp