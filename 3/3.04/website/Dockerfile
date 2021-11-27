# $ docker build . -t colorcontent && docker run -p 3000:80 colorcontent
# $ kubectl apply -f manifests/service.yaml
# $ kubectl apply -f manifests/deployment.yaml
# $ kubectl get pods 
# $ kubectl get svc
# $ kubectl kustomize .
# $ kubectl apply -k .
# $ kubectl delete -k .
# $ gcloud iam service-accounts create github-actions
# $ gcloud iam service-accounts list
# $ gcloud iam service-accounts keys create ./private-key.json --iam-account=<EMAIL>
# $ export GKE_SA_KEY=$(cat private-key.json | base64)
# $ echo $GKE_SA_KEY
# $ git clone https://github.com/jylhakos/DevOpsWithKubernetes.git
# $ git commit -m "3.03"
# $ kubectl create namespace ${GITHUB_REF#refs/heads/} || true
# $ kubectl config set-context --current --namespace=${GITHUB_REF#refs/heads/}

FROM nginx:1.19-alpine

COPY index.html /usr/share/nginx/html
