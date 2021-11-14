# $ docker build -t <USER_NAME>/app-0-writer .
# $ docker push <USER_NAME>/app-0-writer:tagname
# $ docker run -d -p 3001:3001 --name app-0-writer <USER_NAME>/app-0-writer
# $ kubectl delete -f manifests/service.yaml
# $ kubectl apply -f manifests/
# $ kubectl get svc
# $ kubectl get ing

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]