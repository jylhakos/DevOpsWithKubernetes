# $ docker build -t <USER_NAME>/app-0-reader .
# $ docker push <USER_NAME>/app-0-reader:tagname
# $ docker run -d -p 3000:3000 --name app-0-reader <USER_NAME>/app-0-reader
# $ kubectl delete -f manifests/service.yaml
# $ kubectl apply -f manifests/
# $ kubectl get svc
# $ kubectl get ing
# http://localhost:8081

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]