# $ docker build -t <USER_NAME>/todo-backend-db:2.0.8 .
# $ docker push <USER_NAME>/todo-backend-db:2.0.8
# $ docker exec k3d-k3s-default-agent-0 mkdir -p /var/lib/postgresql/data/pgdata
# $ kubectl create namespace <NAME_SPACE>
# $ kubectl delete configmap app-db-env -n todos-db-namespace
# $ kubectl create configmap app-db-env -n todos-db-namespace --from-env-file=.env
# $ kubectl get configmap -n todos-db-namespace
# $ kubectl describe configMap app-db-env -n todos-db-namespace
# $ kubectl delete -f manifests/
# $ kubectl delete -f manifests/deployment-backend.yaml -n todos-db-namespace
# $ kubectl apply -f manifests/
# $ kubectl create -f manifests/deployment-backend.yaml -n todos-db-namespace
# $ kubectl get pods -n todos-db-namespace
# $ kubectl get svc -n todos-db-namespace
# $ kubectl get ing -n todos-db-namespace
# $ kubectl describe deployment todos-backend-db-dep -n todos-db-namespace
# $ kubectl describe pod <POD_NAME> -n <NAME_SPACE>
# $ kubectl logs <POD_NAME> -c <CONTAINER_NAME> -n todos-db-namespace
# $ kubectl logs <POD_NAME> -n <NAME_SPACE>

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

EXPOSE 3002

CMD ["npm", "start"]