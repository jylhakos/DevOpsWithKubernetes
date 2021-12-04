## k3d

$ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2

## kubectl

$ kubectl create namespace app-db-namespace

$ kubectl create configmap app-db-env -n app-db-namespace --from-env-file=.env

$ kubectl describe configMap app-db-env -n app-db-namespace

$ kubectl apply -f manifests/ingress.yaml -n app-db-namespace

$ kubectl apply -f manifests/service-app-0.yaml -n app-db-namespace

$ kubectl apply -f manifests/service-app-2.yaml -n app-db-namespace

$ kubectl apply -f manifests/deployment-app-0-db.yaml -n app-db-namespace

$ kubectl apply -f manifests/deployment-app-2-db.yaml -n app-db-namespace

$ kubectl apply -f manifests/persistentvolumeclaim.yaml -n app-db-namespace

$ kubectl apply -f manifests/persistentvolume.yaml -n app-db-namespace

$ kubectl apply -f manifests/persistentvolume.yaml -n app-db-namespace

$ kubectl apply -f manifests/service-postgresql.yaml -n app-db-namespace

$ kubectl apply -f manifests/postgresql.yaml -n app-db-namespace

$ kubectl rollout undo deployment <DEPLOYMENT_NAME> -n app-db-namespace

$ kubectl get ing -n app-db-namespace

$ kubectl get svc -n app-db-namespace

$ kubectl get pods -n app-db-namespace

$ kubectl get pods -n app-db-namespace

$ kubectl get pods -n app-db-namespace --watch

$ kubectl describe pod <POD_NAME> -n app-db-namespace

$ kubectl exec -ti postgresql-ss-0 -n app-db-namespace -- env PGPASSWORD=postgres psql -U postgres

## Docker

$ docker build -t <USER_NAME>/app-0-db:v1 .

$ docker build -t <USER_NAME>/app-2-db:v1 .

$ docker exec k3d-k3s-default-agent-0 mkdir -p <VOLUME_PATH>
   

## Overview of kubectl

https://kubernetes.io/docs/reference/kubectl/overview/

## PostgreSQL

$ journalctl -u postgresql

$ systemctl status postgresql

postgres=# \c postgres
 
postgres=# ALTER USER postgres PASSWORD 'postgres';

Click the link to learn PostgreSQL.

https://www.postgresql.org/docs/
