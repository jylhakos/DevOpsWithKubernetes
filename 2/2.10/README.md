$ kubectl get svc -n <NAME_SPACE>

$ kubectl exec -ti <POD_NAME> sh -n <NAME_SPACE>
 
 /usr/src/app # apk --no-cache add curl
 
 /usr/src/app # /usr/bin/curl -X POST http://<IP>:3001/todos -H 'Content-Type: application/json' -d '{"content":"........."}'