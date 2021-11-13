# $ docker build -t <USER_NAME>/app-1:1.05 .
# $ docker run -d -p 3000:3000 --name app-1 <USER_NAME>/app-1:1.05
# $ docker login
# $ docker push <USER_NAME>/app-1:1.05
# $ kubectl create deployment app-1 --image=<USER_NAME>/app-1:1.05
# $ kubectl get deployments
# $ kubectl delete deployment app-1
# $ kubectl apply -f manifests/deployment.yaml
# $ kubectl delete -f manifests/deployment.yaml
# $ kubectl get po
# $ kubectl port-forward app-1:1.05 3003:3000
# http://localhost:3003

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]