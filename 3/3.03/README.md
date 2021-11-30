# Deploying to Google Kubernetes Engine

$ gcloud iam service-accounts create github-actions

$ gcloud iam service-accounts list

$ gcloud iam service-accounts keys create ./private-key.json --iam-account=<EMAIL>

$ export GKE_SA_KEY=$(cat private-key.json | base64)

$ echo $GKE_SA_KEY

$ git clone https://github.com/jylhakos/DevOpsWithKubernetes.git

$ git commit -m "3.03"

$ kubectl apply -k .

A link to kustomize

https://github.com/kubernetes-sigs/kustomize