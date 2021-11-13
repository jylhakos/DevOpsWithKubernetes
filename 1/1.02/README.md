# 1.02 - Deploy a containerized application on a cluster.  

$ docker build -t jylhakos/app-1.02 .  
$ docker run -d --name app-1.02 jylhakos/app-1.02  
$ docker exec -it app-1.02 /bin/sh  
/usr/src/app # ps -ef  
$ docker container ls  
$ docker images  
$ docker inspect <IMAGE_ID>  
$ docker stop $(docker ps -a -q)  
$ docker rmi $(docker images -q)  
$ docker rm $(docker ps -a -q)  
$ docker login  
$ docker push jylhakos/app-1.02:latest  
$ kubectl create deployment app-1.02 --image=test/app-1.02  
$ kubectl get deployments  
$ kubectl logs app-1.02  
$ kubectl delete deployment app-1.02  
