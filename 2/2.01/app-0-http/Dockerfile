# $ docker build -t <USER_NAME>/app-0-shared .
# $ docker push <USER_NAME>/app-0-shared:tagname
# $ docker pull docker.io/<USER_NAME>/app-0-shared
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