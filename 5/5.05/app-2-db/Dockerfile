# $ docker build -t <USER_NAME>/app-2-db:v4.01 .
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /tmp/kube
# $ k3d cluster delete
# $ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2 --k3s-arg "--disable=traefik@server:0"
# $ kubectl cluster-info
# $ kubectl create namespace <NAME_SPACE>
# $ kubectl create configmap app-db-env -n <NAME_SPACE> --from-env-file=.env
# $ kubectl create -f manifests/postgres-secrets.yaml -n app-db-namespace
# $ kubectl get secret postgres-secret-config -n 
# $ kubectl apply -f manifests/volume -n app-db-namespace
# $ kubectl apply -f manifests/db -n app-db-namespace
# $ lsof -ti:8080 | sudo xargs kill -9
# $ sudo -i -u postgres 
# $ psql
# $ sudo -u postgres psql
# $ kubectl get ksvc
# $ curl -H "Host: <URL>" http://localhost:8081
# $ kubectl describe svc <SERVICE>
# $ kubectl get revisions,routes
# $ kubectl exec <DATABASE_SERVER> -c db -- psql -U postgres -c 'SELECT * FROM <TABLE>;'

FROM node:alpine

WORKDIR /usr/src/app

RUN npm install npm@latest -g

RUN npm cache clean --force

RUN npm config rm proxy 

RUN npm config rm https-proxy

COPY package* ./

RUN npm ci

RUN apk --no-cache add curl

COPY . .

EXPOSE 3001

CMD ["npm", "start"]