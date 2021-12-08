# $ docker build -t <USER_NAME>/todo-backend-db:v4.24 .
# $ docker push <USER_NAME>/todo-backend-db:v4.05
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /var/lib/postgresql/data/
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube
# $ kubectl create namespace <NAME_SPACE>
# $ kubectl delete configmap app-db-env -n todos-db-namespace
# $ kubectl create configmap app-db-env -n todos-db-namespace --from-env-file=.env
# $ kubectl get configmap -n todos-db-namespace
# $ kubectl describe configMap app-db-env -n todos-db-namespace
# kubectl -n prometheus port-forward <POD_NAME> 3000
# http://localhost:3000/
# GRAFANA: USER: admin PASSWORD: prom-operator
# https://linuxblog.xyz/posts/kube-prometheus-stack/
# $ kubectl create namespace loki
# $ helm repo add loki https://grafana.github.io/loki/charts
# $ helm repo update
# $ helm install <NATS_NAME> nats/nats
# $ kubectl get pods
# $ kubectl -n prometheus get prometheus
# $ kubectl describe prometheus -n prometheus <POD_NATS_NAME> 
# $ kubectl describe svc <NATS_NAME>
# $ kubectl get pods -n prometheus
# $ sudo lsof -ti:9090 | sudo xargs kill -9
# $ kubectl -n prometheus port-forward -n prometheus <PROMETHEUES_KUBE_STACK_NAME> 9090
# $ kubectl -n prometheus port-forward <PROMETHEUES_KUBE_STACK_GRAFANA_NAME> 3000
# $ kubectl port-forward todos-nats-0 7777:7777
# $ docker run -p 4222:4222 -p 8222:8222 -ti nats:latest

FROM node:alpine

WORKDIR /usr/src/app

RUN rm -rf node_modules

RUN rm -rf package-lock.json

RUN apk --no-cache add curl

COPY package* ./

RUN npm install

COPY . .

EXPOSE 3002

CMD ["npm", "start"]