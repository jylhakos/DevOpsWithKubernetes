**Automated Canary Releases**
```
$ kubectl apply -k github.com/fluxcd/flagger/kustomize/linkerd

$ kubectl -n linkerd rollout status deploy/flagger

$ kubectl -n todos-db-namespace get svc
```

NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE

postgresql-svc                 ClusterIP   None            <none>        5432/TCP   13m

backend-db-service             ClusterIP   10.43.176.174   <none>        80/TCP     11m

todos-backend-db-dep-canary    ClusterIP   10.43.83.206    <none>        9898/TCP   3m5s

todos-backend-db-dep-primary   ClusterIP   10.43.17.243    <none>        9898/TCP   3m5s

todos-backend-db-dep           ClusterIP   10.43.214.160   <none>        9898/TCP   2m25s

A link to Linkerd Canary Deployments

https://docs.flagger.app/tutorials/linkerd-progressive-delivery


![alt text](https://github.com/jylhakos/DevOpsWithKubernetes/blob/main/5/5.03/manifests/5.03.png?raw=true)





