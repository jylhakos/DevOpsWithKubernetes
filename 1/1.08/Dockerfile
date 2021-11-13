# $ docker build -t <USER_NAME>/app-1:1.08 .
# $ docker run -d -p 3000:3000 --name app-1 <USER_NAME>/app-1:1.08
# $ k3d cluster delete
# $ k3d cluster create --port 8082:30080@agent:0 -p 8081:80@loadbalancer --agents 2
# $ kubectl delete -f manifests/
# $ kubectl apply -f manifests/
# http://localhost:8081

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]