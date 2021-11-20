# $ sudo chmod 777 -R /usr/src/app/files
# $ docker build -t <USER_NAME>/todo-finder .
# $ docker push <USER_NAME>//todo-finder:tagname
# $ docker info | grep -i cgroup
# $ k3d cluster delete
# $ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
# $ kubectl cluster-info
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube
# $ kubectl delete -f manifests/
# $ kubectl apply -f manifests/
# $ kubectl get pods
# $ kubectl describe deployment todos-dep
# $ kubectl describe pod <POD_NAME>
# $ kubectl get svc
# $ kubectl get ing
# $ kubectl logs <POD_NAME> -c todo-finder

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

RUN mkdir /usr/src/app/files && chmod -R 777 /usr/src/app/files

COPY . .

EXPOSE 3001

CMD ["npm", "start"]