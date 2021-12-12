# $ docker build -t <USER_NAME>/todo-response-db:v4.05 .
# $ docker push <USER_NAME>/todo-response:v4.05
# $ docker info | grep -i cgroup
# $ k3d cluster delete
# $ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
# $ kubectl cluster-info
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube
# $ kubectl create service clusterip todo-response --tcp=8081:80
# $ kubectl create service clusterip todo-finder --tcp=8082:30080
# $ kubectl delete -f manifests/
# $ kubectl create namespace <NAME_SPACE>
# $ kubectl apply -f manifests/
# $ kubectl get pods -n todos-db-namespace
# $ kubectl get all --all-namespaces
# $ kubectl get pods -n <NAME_SPACE>
# $ kubectl logs <POD_NAME> -n <NAME_SPACE>
# $ kubectl describe deployment todos-dep
# $ kubectl get svc
# $ kubectl get ing
# $ kubectl get nodes
# $ kubectl logs <POD_NAME> -c todo-response

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]