## Prometheus

$ kubectl create namespace prometheus

$ helm install prometheus-community/kube-prometheus-stack --generate-name --namespace prometheus

$ sudo lsof -ti:9090 | sudo xargs kill -9

$ kubectl get pods -n prometheus 

NAME                                                              READY   STATUS    RESTARTS   AGE
kube-prometheus-stack-1638667682-prometheus-node-exporter-xbgxr   1/1     Running   0          3m16s
kube-prometheus-stack-1638667682-kube-state-metrics-6b5b67wzwhk   1/1     Running   0          3m16s
kube-prometheus-stack-1638667682-prometheus-node-exporter-tf7df   1/1     Running   0          3m16s
kube-prometheus-stack-1638-operator-5dc9b95df7-bp7xn              1/1     Running   0          3m16s
kube-prometheus-stack-1638667682-prometheus-node-exporter-h2pbb   1/1     Running   0          3m16s
alertmanager-kube-prometheus-stack-1638-alertmanager-0            2/2     Running   0          2m55s
prometheus-kube-prometheus-stack-1638-prometheus-0                2/2     Running   0          2m54s
kube-prometheus-stack-1638667682-grafana-57bfbfdd99-tnbrr         2/2     Running   0          3m16s

$ kubectl port-forward prometheus-kube-prometheus-stack-1638-prometheus-0 9090:9090 -n prometheus

$ netstat -ntlp | grep 9090

![alt text](https://github.com/[username]/[reponame]/blob/[branch]/image.jpg?raw=true)

A link to Prometheus

https://prometheus.io/docs/prometheus/latest/querying/basics/

