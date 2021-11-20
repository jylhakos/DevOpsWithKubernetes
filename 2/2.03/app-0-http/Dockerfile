# $ docker build -t <USER_NAME>/app-0-http .
# $ docker push <USER_NAME>/app-0-http:tagname
# $ docker run -p 3000:3000 --name app-0-http <USER_NAME>/app-0-http 
# $ docker pull docker.io/<USER_NAME>/app-0-http
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