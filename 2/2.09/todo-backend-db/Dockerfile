# $ docker build -t <USER_NAME>/todo-backend-db:2.9.14 .
# $ docker push <USER_NAME>/todo-backend-db:2.9.14
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
# $ kubectl exec <POD_NAME> -n todos-db-namespace -- printenv
# $ kubectl get jobs --watch -n todos-db-namespace
# $ kubectl create -f manifests/shell-script.yaml
# $ kubectl describe cronjob -n todos-db-namespace
# $ kubectl describe configmap shell-script -n todos-db-namespace 
# $ kubectl delete jobs $(kubectl get jobs -n todos-db-namespace | awk '$2 ~ 1/1' | awk '{print $1}')
# $ kubectl delete job $(kubectl get jobs -n todos-db-namespace | awk '$2 ~ 1' | awk '{print $1}')
# $ kubectl get jobs --all-namespaces | sed '1d' | awk '{ print $2, "--namespace", $1 }' | while read line; do kubectl delete jobs $line; done
# $ kubectl delete job $(kubectl get jobs --all-namespaces -o jsonpath='{.items[?(@.status.completionTime)].metadata.name}')

FROM node:alpine

WORKDIR /usr/src/app

RUN rm -rf node_modules

RUN rm -rf package-lock.json

RUN apk --no-cache add curl

COPY package* ./

RUN npm install

COPY . .

RUN chmod a+x script.sh

#COPY script-cron /etc/cron.d/script-cron

# RUN ls -la /etc/cron.d/script-cron

#RUN chmod 0644 /etc/cron.d/script-cron

RUN export TODO_URL="2.09" && echo $TODO_URL

#RUN crontab /etc/cron.d/script-cron

VOLUME /etc/data

RUN mkdir -p /etc/data/ && touch /etc/data/url.txt

EXPOSE 3002

CMD ["npm", "start"]