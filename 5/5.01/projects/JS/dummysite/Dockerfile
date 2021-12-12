# $ npm install @kubernetes/client-node --save
# $ kubectl create namespace dummysite
# $ kubectl apply -f manifests/resourcedefinition.yaml
# $ kubectl apply -f manifests/dummysite.yaml
# $ kubectl describe dummysite.dummysite.dwk/dummysite
# $ kubectl get dummy

FROM node:alpine

WORKDIR /usr/src/app

COPY . .

ENTRYPOINT ["node", "index.js"]