# $ docker build -t <USER_NAME>/app-1:1.04 .
# $ docker login
# $ docker push <USER_NAME>/app-1:1.04
# $ kubectl create deployment app-1-dep --image=<USER_NAME>/app-1:1.04
# $ kubectl get deployments
# $ kubectl delete deployment app-1
# $ kubectl apply -f manifests/deployment.yaml
# $ kubectl delete -f manifests/deployment.yaml

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]