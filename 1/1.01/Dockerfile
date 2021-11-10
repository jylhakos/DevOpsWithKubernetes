# $ docker build -t <USER_NAME>/dwk-app1 .
# $ docker run -d --name <CONTAINER_NAME> <USER_NAME>/dwk-app1
# $ docker exec -it a9999c349153 /bin/sh
# /usr/src/app # ps -ef
# $ docker container ls
# $ docker images
# $ docker inspect <IMAGE_ID>

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]