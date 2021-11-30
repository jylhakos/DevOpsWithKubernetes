# Continuous deployment from Github

$ kubectl kustomize .

$ kubectl apply -k .

$ kubectl delete -k .

$ gcloud iam service-accounts create github-actions

$ gcloud iam service-accounts list

$ gcloud iam service-accounts keys create ./private-key.json --iam-account=<EMAIL>

$ export GKE_SA_KEY=$(cat private-key.json | base64)

$ echo $GKE_SA_KEY

$ git branch -m master main

$ git push -u origin main

$ git switch -c 3.04

$ git push origin 3.04

$ git checkout main

$ git fetch origin

$ git merge 3.04

$ git reset --hard origin/main
