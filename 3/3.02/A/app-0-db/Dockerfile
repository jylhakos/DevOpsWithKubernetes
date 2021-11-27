# $ docker build -t <USER_NAME>/app-0-db:3.0.6 .
# $ docker push <USER_NAME>/app-0-db:tagname
# $ docker run -p 3000:3000 --name app-0-db <USER_NAME>/app-0-db 
# $ docker pull docker.io/<USER_NAME>/app-0-db
# $ kubectl delete -f manifests/
# $ kubectl apply -f manifests/
# $ kubectl get svc
# $ kubectl get ing
# $ kubectl get svc --all-namespaces
# http://localhost:8081/

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]