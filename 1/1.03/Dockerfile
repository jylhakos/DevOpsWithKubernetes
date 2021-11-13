# $ docker build -t jylhakos/app-0:1.03 .
# $ docker run -d --name app-0 jylhakos/app-0
# $ docker exec -it app-0 /bin/sh
# /usr/src/app # ps -ef
# $ docker container ls
# $ docker images
# $ docker inspect <IMAGE_ID>
# $ docker stop $(docker ps -a -q)
# $ docker rmi $(docker images -q)
# $ docker rm $(docker ps -a -q)
# $ docker login
# $ docker push jylhakos/app-0:1.03
# $ kubectl create deployment app-0-dep --image=jylhakos/app-0:1.03
# $ kubectl get deployments
# $ kubectl delete deployment app-0
# $ kubectl apply -f manifests/deployment.yaml
# $ kubectl delete -f manifests/deployment.yaml

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]