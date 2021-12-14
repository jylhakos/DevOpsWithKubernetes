**Serverless**

## k3d ##

```
$ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2 --k3s-arg "--disable=traefik@server:0"
```

INFO[0000] portmapping '8081:80' targets the loadbalancer: defaulting to [servers:*:proxy agents:*:proxy]

INFO[0000] Prep: Network

INFO[0000] Re-using existing network 'k3d-k3s-default' (db2f0bcb7dfa8d1dba47356280e9a5028ac817bdba9d927e4c3d6597cd965886)

INFO[0000] Created volume 'k3d-k3s-default-images'

INFO[0000] Starting new tools node...

INFO[0000] Starting Node 'k3d-k3s-default-tools'

INFO[0001] Creating node 'k3d-k3s-default-server-0'

INFO[0001] Creating node 'k3d-k3s-default-agent-0'

INFO[0001] Creating node 'k3d-k3s-default-agent-1'

INFO[0001] Creating LoadBalancer 'k3d-k3s-default-serverlb'

INFO[0001] Using the k3d-tools node to gather environment information 

INFO[0001] HostIP: using network gateway 172.19.0.1 address 

INFO[0001] Starting cluster 'k3s-default'   

INFO[0001] Starting servers... 

INFO[0001] Starting Node 'k3d-k3s-default-server-0'   

INFO[0005] Starting agents...   

INFO[0005] Starting Node 'k3d-k3s-default-agent-1'    

INFO[0005] Starting Node 'k3d-k3s-default-agent-0'      
INFO[0017] Starting helpers...                          
INFO[0017] Starting Node 'k3d-k3s-default-serverlb'  

INFO[0024] Injecting '172.19.0.1 host.k3d.internal' into /etc/hosts of all nodes...

INFO[0024] Injecting records for host.k3d.internal and for 4 network members into CoreDNS configmap... 

INFO[0025] Cluster 'k3s-default' created successfully! 

INFO[0025] You can now use it like this: 

$ kubectl cluster-info

## Knative ##

```
$ kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.0.0/serving-crds.yaml

$ kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.0.0/serving-core.yaml
```

By default, all incoming requests to your Knative service are sent to port 8080.

A link to Knative

https://knative.dev/docs/install/serving/install-serving-with-yaml/

## Contour ##

```
$ kubectl apply -f https://github.com/knative/net-contour/releases/download/knative-v1.0.0/contour.yaml

$ kubectl apply -f https://github.com/knative/net-contour/releases/download/knative-v1.0.0/net-contour.yaml
```

## Knative Serving to use Contour ##

```
$ kubectl patch configmap/config-contour \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress-class":"contour.ingress.networking.knative.dev"}}'

$ kubectl get revisions, routes

$ kubectl get ksvc
```

NAME       URL                                   LATESTCREATED   LATESTREADY    READY   REASON

app-2-db   http://app-2-db.default.example.com   app-2-db-app    app-2-db-app   True

```
$ URL=$(kubectl get ksvc <KNATIVE_SERVICE_NAME> -o jsonpath='{.status.url}')

$ curl -H "Host: $URL" http://localhost:8081
```
