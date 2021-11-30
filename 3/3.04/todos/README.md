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

$ git add .

$ git switch -c <BRANCH_NAME>

$ git commit -m "3.04"

$ git push origin <BRANCH_NAME>

$ git checkout main

$ git fetch origin

$ git merge <BRANCH_NAME>

$ git reset --hard origin/main

$ git branch --delete <BRANCH_NAME>

![alt text](https://github.com/jylhakos/DevOpsWithKubernetes/blob/main/3/3.04/todos/3.04.png?raw=true)


