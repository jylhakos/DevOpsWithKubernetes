# $ docker tag <IMAGE_ID> <USER_NAME>/<IMAGE_ID>
$ $ docker push <USER_NAME>/<IMAGE_ID>
# $ docker build -t <USER_NAME>/app-0:1.01 .
# $ docker run -d --name <CONTAINER_NAME> <USER_NAME>/app-0:1.01
# $ docker exec -it <IMAGE_ID> /bin/sh
# $ sudo chown -R $USER $HOME/.kube
# /usr/src/app # ps -ef
# $ docker login
# $ docker push <USER_NAME>/app-0:1.01
# $ docker container ls
# $ docker images
# $ docker inspect <IMAGE_ID>
# $ kubectl create deployment app-0 --image=<USER_NAME>/app-0:1.01

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]