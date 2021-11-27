$ kubectl get pods -n app-db-namespace

$ kubectl exec -ti postgresql-ss-0 -n app-db-namespace -- env PGPASSWORD=postgres psql -U postgres

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges  

-----------+----------+----------+------------+------------+-----------------------

 
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 


postgres=# \c postgres
 
postgres=# ALTER USER postgres PASSWORD 'postgres';

$ kubectl apply -f manifests/deployment-app-2-db.yaml -n app-db-namespace

$ kubectl apply -f manifests/deployment-app-0-db.yaml -n app-db-namespace

$ kubectl logs app-2-db-dep-795cdf759-qf9fp -n app-db-namespace
