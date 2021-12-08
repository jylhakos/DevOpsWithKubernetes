## NATS on K8S

The NATS server listens for client connections on TCP Port 4222

$ helm repo add nats https://nats-io.github.io/k8s/helm/charts/

$ helm install <NATS_NAME> nats/nats

NAME: todos-nats
LAST DEPLOYED: Mon Dec 6 15:06:52 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
You can find more information about running NATS on Kubernetes
in the NATS documentation website:

https://docs.nats.io/nats-on-kubernetes/nats-kubernetes

NATS Box has been deployed into your cluster, you can
now use the NATS tools within the container as follows:

$ kubectl exec -n default -it deployment/todos-nats-box -- /bin/sh -l

nats-box:`~#` nats-sub test &

nats-box:`~#` nats-pub test hi

nats-box:`~#` nc todos-nats 4222

$ kubectl -n prometheus get prometheus

$ kubectl describe prometheus -n prometheus <POD_NATS_NAME> 

$ kubectl describe svc <NATS_NAME>

$ kubectl get pods -n prometheus

$ lsof -ti:9090 | sudo xargs kill -9

$ kubectl -n prometheus port-forward -n prometheus <PROMETHEUES_KUBE_STACK_NAME> 9090

$ kubectl -n prometheus port-forward <PROMETHEUES_KUBE_STACK_GRAFANA_NAME> 3000

$ kubectl port-forward <POD_NATS_NAME> 7777:7777

$ curl 'http://localhost:9090/api/v1/query?query=nats_varz_cpu'

{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"nats_varz_cpu","container":"metrics","endpoint":"metrics","instance":"10.42.2.70:7777","job":"todos-nats","namespace":"default","pod":"todos-nats-0","server_id":"NCIH3J5TTBS7LHHCRLRMWT4KCUMAWBP2SHCYTPLUTRWABD5NCVXL6EQV","service":"todos-nats"},"value":[1638779099.682,"0"]}]}}

$ kubectl port-forward todos-nats-0 4222:0.0.0.0:4222

Slack Nats

https://github.com/natsflow/slack-nats

![alt text](https://github.com/[username]/[reponame]/blob/[branch]/image.jpg?raw=true)

