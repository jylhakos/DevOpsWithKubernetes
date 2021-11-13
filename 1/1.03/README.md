# 1.03 - Using kubectl to Create a Deployment

$ docker build -t jylhakos/app-1.03 .  
$ docker run -d --name app-1.03 jylhakos/app-1.03  
$ docker login  
$ docker push jylhakos/app-1.03:latest  
$ kubectl create deployment app-1.03 --image=test/app-1.03  
$ kubectl logs app-1.03  
$ kubectl apply -f manifests/deployment.yaml  
$ kubectl delete -f manifests/deployment.yaml  