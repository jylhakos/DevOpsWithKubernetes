# $ sudo apt-get upgrade docker-ce
# $ sudo systemctl restart docker.service
# $ sudo chown -R $USER:$USER /usr/src/app/files
# $ docker build -t <USER_NAME>/app-2-http .
# $ docker push <USER_NAME>/app-2-http
# $ docker pull docker.io/<USER_NAME>/app-2-http
# $ docker info | grep -i cgroup
# $ docker ps
# $ k3d cluster delete
# $ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
# $ kubectl cluster-info
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube
# $ kubectl delete -f manifests/
# $ kubectl apply -f manifests/
# $ kubectl get svc
# $ kubectl get ing
# $ kubectl get pods
# $ kubectl get nodes
# $ kubectl describe deployment app-0-2-http-dep
# $ kubectl logs <POD_NAME> -c app-2-http
# $ kubectl describe pod <POD_NAME>
# http://localhost:8081/pingpong

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

RUN mkdir /usr/src/app/files && chmod -R 777 /usr/src/app/files

CMD ["npm", "start"]