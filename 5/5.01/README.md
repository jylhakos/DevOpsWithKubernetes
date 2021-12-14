**Javascript Kubernetes Clients**
 
 A link to Javascript clients for Kubernetes

 https://github.com/kubernetes-client/javascript/tree/master/examples

**Go client for Kubernetes** 

**kubebuilder**
Install kubebuilder
```
$ ./install.sh

$ mkdir <PROJECT_DIRECTORY>
```
Initializing a project
```
$ go mod init <PROJECT.DOMAIN>

$ kubebuilder init --plugins go/v3 --domain <PROJECT.DOMAIN> --repo <REPOSITORY> --skip-go-version-check
```

**Kubernetes API**

Create new Kubernetes API, CRD and Controller
```
$ kubebuilder create api --group <GROUP> --version v3 --kind <RESOURCE>

``` 
**CustomResourceDefinitions**

Fill in CRD `controller/api/v1/<RESOURCE_TYPES>.go`

The controller watches defined resources and when an event happens in the resources, then the controller calls the Reconcile function.

**reconciler**

Write reconciler function `controllers/countdown_controller.go`

Make `make`

deploy CRD's to your cluster `make install`

```
$ make run 
```

Apply an application 

```
$ kubectl apply -f manifests/<FILE>.yaml
```

**Docker**

Deployment to Docker
```
$ make docker-build docker-push IMG=<USER_NAME>/<IMAGE_NAME>


$ kubectl apply -f ./manifests/
```

A link to kubebuilder

https://github.com/kubernetes-sigs/kubebuilder

A link to reconcile

https://godoc.org/github.com/kubernetes-sigs/controller-runtime/pkg/reconcile

