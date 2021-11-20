# $ docker build -t <USER_NAME>/todo-backend .

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

EXPOSE 3002

CMD ["npm", "start"]