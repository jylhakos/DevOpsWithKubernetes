# $ kubectl apply -f manifests/clusterrole.yaml
# $ kubectl apply -f manifests/clusterrolebinding.yaml
# $ kubectl apply -f manifests/serviceaccount.yaml
# $ kubectl apply -f manifests/controller.yaml
# $ kubectl port-forward $(kubectl get pod -l app=dummysite-controller -o=name) 8000

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

CMD ["npm", "start"]