
$ kubectl apply -f manifests/deployment-app-2-db.yaml -n app-db-namespace

$ kubectl apply -f manifests/deployment-app-0-db.yaml -n app-db-namespace

$ kubectl get pods -n app-db-namespace

$ kubectl exec -ti postgresql-ss-0 -n app-db-namespace -- env PGPASSWORD=postgres psql -U postgres

Overview of kubectl

https://kubernetes.io/docs/reference/kubectl/overview/

PostgreSQL

$ journalctl -u postgresql

$ systemctl status postgresql

postgres=# \c postgres
 
postgres=# ALTER USER postgres PASSWORD 'postgres';

Click the link to learn PostgreSQL.

https://www.postgresql.org/docs/
