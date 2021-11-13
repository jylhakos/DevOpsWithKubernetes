# $ docker build -t <USER_NAME>/app-0:1.07 .
# $ docker run -d -p 3000:3000 --name app-1 <USER_NAME>/app-0:1.07
# $ kubectl delete -f manifests/
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