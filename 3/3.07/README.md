
PostgreSQL stores data in files, and the files are stored in persistent volume claims. 

PostgreSQL runs as a service in a Kubernetes cluster and that stores its database files in PersistentVolumeClaims.

A PersistentVolumeClaim must be created and made available to a PostgreSQL instance.

PostgreSQL service remains unchanged even if a container or pod is moved to a different node.

$ kubectl get pods

$ kubectl exec -ti <POD_NAME> -- env PGPASSWORD=postgres psql -U postgres

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

A link to reference

https://cloud.google.com/architecture/deploying-highly-available-postgresql-with-gke


![alt text](https://github.com/jylhakos/DevOpsWithKubernetes/blob/main/3/3.07/manifests/3.07.png?raw=true)