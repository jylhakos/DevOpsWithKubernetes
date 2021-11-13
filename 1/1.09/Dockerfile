# $ docker build -t <USER_NAME>/app-2:1.09 .
# $ docker run -d -p 3001:3000 --name app-1 <USER_NAME>/app-2:1.09
# $ kubectl delete -f manifests/service.yaml
# $ kubectl apply -f manifests/service.yaml
# $ kubectl create deployment app-0 --image=<USER_ID>/app-0:1.07
# $ kubectl expose deployment app-0 --type=NodePort --port=8081
# $ kubectl create deployment app-2 --image=<USER_ID>/app-2:1.08
# $ kubectl expose deployment app-2 --type=NodePort --port=8082
# $ kubectl apply -f manifests/
# $ cd 1.07
# $ kubectl apply -f manifests/deployment.yaml
# $ kubectl apply -f manifests/service.yaml
# $ kubectl get pods
# $ kubectl get svc
# $ kubectl get ing
# http://localhost:8081/
# http://localhost:8081/pingpong

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]