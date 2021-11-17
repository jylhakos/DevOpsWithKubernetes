# $ docker build -t <USER_NAME>/app-0-http .
# $ docker push <USER_NAME>/app-0-http:tagname
# $ docker pull docker.io/<USER_NAME>/app-0-http
# $ kubectl delete -f manifests/
# $ kubectl apply -f manifests/
# $ kubectl get svc
# $ kubectl get ing
# http://localhost:8081/

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]