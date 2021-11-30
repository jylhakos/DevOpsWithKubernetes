# $ gcloud iam service-accounts create github-actions
# $ gcloud iam service-accounts list
# $ gcloud iam service-accounts keys create ./private-key.json --iam-account=<EMAIL>
# $ export GKE_SA_KEY=$(cat private-key.json | base64)
# $ echo $GKE_SA_KEY
# $ kubectl apply -f manifests/persistentvolume.yaml -n <NAMESPACE>
# $ kubectl apply -f manifests/persistentvolumeclaim.yaml -n <NAMESPACE>
# $ kubectl apply -f manifests/postgresql.yaml -n <NAMESPACE>
# $ kubectl apply -f manifests/service-postgresql.yaml -n <NAMESPACE>
# $ git commit -m "3.04"
# $ kubectl kustomize build . 
# $ git branch -m master main
# $ git push -u origin main
# $ git switch -c <BRANCH_NAME>
# $ git add .
# $ git commit -m "3.04"
# $ git push origin <BRANCH_NAME>
# $ git checkout main
# $ git fetch origin
# $ git merge <BRANCH_NAME>
# $ git reset --hard origin/main
# $ git branch --delete <BRANCH_NAME>

FROM node:alpine

WORKDIR /usr/src/app

RUN apk --no-cache add curl

COPY ./todo-backend-db/package*.json ./

RUN npm ci

COPY . .

EXPOSE 3002

CMD ["npm", "start"]
