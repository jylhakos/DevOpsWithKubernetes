# $ docker build -t <USER_NAME>/dwk-app3-image-response .
# $ docker push <USER_NAME>/dwk-app3-image-response:tagname
# $ k3d cluster delete
# $ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
# $ kubectl cluster-info
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube
# $ kubectl cluster-info
# $ kubectl delete -f manifests/
# $ kubectl apply -f manifests/
# $ kubectl get svc
# $ kubectl get ing
# $ kubectl logs <POD_NAME> -c image-response

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]