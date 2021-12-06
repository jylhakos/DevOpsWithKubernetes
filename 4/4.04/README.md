## Container Metrics

sum(rate(container_cpu_usage_seconds_total{namespace="$namespace",pod_name="$podName",container_name="$containerName"}[5m]

![alt text](https://github.com/[username]/[reponame]/blob/[branch]/image.jpg?raw=true)

A link to container CPU utilization

https://rancher.com/docs/rancher/v2.0-v2.4/en/cluster-admin/tools/cluster-monitoring/expression/#container-cpu-utilization

## Argo Rollouts

$ kubectl create namespace argo-rollouts

$ kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

A link to Argo Rollouts

https://argoproj.github.io/argo-rollouts/


