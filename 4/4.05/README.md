## kubectl

$ kubectl create namespace todos-db-namespace

$ kubectl create configmap app-db-env -n todos-db-namespace --from-env-file=.env

$ kubectl apply -f manifests/volume/ -n todos-db-namespace

$ kubectl apply -f manifests/db/ -n todos-db-namespace

$ kubectl apply -f manifests/backend/ -n todos-db-namespace

$ kubectl apply -f manifests/frontend/ -n todos-db-namespace

## .env

BACKEND_URL=http://backend-db-service/todos
FRONTEND_PORT=3000
FINDER_PORT=3001
BACKEND_PORT=3002
PGDATA=/var/lib/postgresql/data/
DB_HOST=postgresql-svc
DB_PORT=5432
DB_SCHEMA=postgres
DB_USER=postgres
POSTGRES_HOST_AUTH_METHOD=trust

![alt text](https://github.com/jylhakos/DevOpsWithKubernetes/blob/main/4/4.05/4.05.png?raw=true)

