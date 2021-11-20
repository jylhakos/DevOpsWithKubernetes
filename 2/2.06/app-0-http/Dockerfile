# $ docker build -t <USER_NAME>/app-0-http .
# $ docker push <USER_NAME>/app-0-http:tagname
# $ docker run -p 3000:3000 --name app-0-http <USER_NAME>/app-0-http 
# $ docker pull docker.io/<USER_NAME>/app-0-http
# $ kubectl delete -f manifests/
# $ kubectl create configmap <MAP_NAME> <DATA_SOURCE>
# $ kubectl delete configmap app-http-env
# $ kubectl create configmap app-http-env --from-env-file=app-0-http/.env
# $ kubectl get configmap -n app-http-namespace
# $ kubectl describe configMap app-http-env -n app-http-namespace
# $ kubectl apply -f manifests/
# $ kubectl get pods -n app-http-namespace
# $ kubectl logs <POD_NAME> -n app-http-namespace
# http://localhost:8082/

FROM node:alpine

WORKDIR /usr/src/app

COPY package* ./

RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]