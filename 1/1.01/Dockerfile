# $ docker build -t jylhakos/app-0:1.01 .
# $ docker run -d --name app-0 jylhakos/app-0:1.01
# $ docker exec -it a9999c349153 /bin/sh
# /usr/src/app # ps -ef
# $ docker container ls
# $ docker images
# $ docker inspect <IMAGE_ID>
# $ docker login
# $ docker push jylhakos/app-0:1.01
# https://hub.docker.com/repository/docker/jylhakos/app-0
# $ docker stop $(docker ps -a -q)
# $ kubectl create deployment app-0-dep --image=docker.io/jylhakos/app-0:1.01

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]