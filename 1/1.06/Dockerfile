# $ docker build -t test/app-1:1.05 .
# $ docker run -d -p 3000:3000 --name app-1 test/app-1:1.05
# $ docker exec -it app-1 /bin/sh
# /usr/src/app # ps -ef
# $ docker container ls
# $ docker images
# $ docker inspect <IMAGE_ID>
# $ docker stop $(docker ps -a -q)
# $ docker rmi $(docker images -q)
# $ docker rm $(docker ps -a -q)
# $ docker login
# $ docker push jylhakos/app-1:1.05
# $ kubectl create deployment app-1 --image=test/app-1:1.05
# $ kubectl get deployments
# $ kubectl logs app-1
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