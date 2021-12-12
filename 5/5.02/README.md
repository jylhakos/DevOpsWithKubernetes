**A service mesh for Kubernetes**
 
```$ curl -fsL https://run.linkerd.io/install | sh```

$ linkerd check --pre

**Linkerd core checks**

kubernetes-api
--------------
√ can initialize the client

√ can query the Kubernetes API

kubernetes-version
------------------
√ is running the minimum Kubernetes API version

√ is running the minimum kubectl version

pre-kubernetes-setup
--------------------
√ control plane namespace does not already exist

√ can create non-namespaced resources

√ can create ServiceAccounts

√ can create Services

√ can create Deployments

√ can create CronJobs

√ can create ConfigMaps

√ can create Secrets

√ can read Secrets

√ can read extension-apiserver-authentication configmap

√ no clock skew detected

linkerd-version
---------------
√ can determine the latest version

√ cli is up-to-date

Status check results are √

$ kubectl get -n <NAMESPACE> deploy -o yaml \ 
						   | linkerd inject -  \ 
						   | kubectl apply -f -

Meshing a Kubernetes resource is done by annotating the resource, or its namespace, with the linkerd.io/inject: enabled Kubernetes annotation.

$ cat <DEPLOYMENT.YAML> | linkerd inject - | kubectl apply -f -

$ echo "$(cat <DEPLOYMENT.YAML> | linkerd inject -)" > <DEPLOYMENT.YAML>

A link to service mesh

https://linkerd.io/


![alt text](https://github.com/jylhakos/DevOpsWithKubernetes/blob/main/5/5.02/5.02.png?raw=true)





