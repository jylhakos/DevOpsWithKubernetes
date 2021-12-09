# $ docker build -t <USER_NAME>/broadcaster .
# $ kubectl apply -f manifests/broadcaster
# $ sudo apt-get install helm
# $ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# $ helm repo add stable https://charts.helm.sh/stable
# $ kubectl create namespace prometheus
# $ helm install prometheus-community/kube-prometheus-stack --generate-name --namespace prometheus
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

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

RUN ls -l

CMD ["npm", "start"]