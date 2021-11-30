# $ gcloud iam service-accounts create github-actions
# $ gcloud iam service-accounts list
# $ gcloud iam service-accounts keys create ./private-key.json --iam-account=<EMAIL>
# $ export GKE_SA_KEY=$(cat private-key.json | base64)
# $ echo $GKE_SA_KEY
# $ git clone https://github.com/jylhakos/DevOpsWithKubernetes.git
# $ git commit -m "3.03"
$ kubectl kustomize build ./todo-backend-db/.

FROM node:alpine

WORKDIR /usr/src/app

RUN rm -rf node_modules

RUN rm -rf package-lock.json

RUN apk --no-cache add curl

COPY ./todo-backend-db/package*.json ./

RUN npm ci

COPY . .

EXPOSE 3002

CMD ["npm", "start"]
