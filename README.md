# Kubernetes

Kubernetes (k8s) is an open-source system for automating deployment, scaling, and management of containerized applications.

A cluster is a group of machines, nodes, that work together.

Kubernetes is intended to be used with a container registry.

**kubectl**

Kubectl is the Kubernetes command-line tool and allows us to interact with the cluster. 

If you need to start the cluster you can run the following command.

$ k3d cluster start

and to stop the cluster by command.

$ k3d cluster stop

Kustomize is a tool that helps with configuration customization and is included in kubectl.

The kustomization.yaml include instructions to use the deployment.yaml and service.yaml files.

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- manifests/deployment.yaml
- manifests/service.yaml
```

**k3d**

You use k3d to create a group of docker containers that run k3s.

**Pod**

A Pod represents an instance of a running process in your cluster and a pod contains one or more containers, such as Docker containers.

ReplicaSets are used to tell how many replicas of a Pod you want for a deployment.

You create a set of identical Pods, called replicas, to run your application. 

Such a set of replicated Pods are created and managed by a controller, such as a Deployment.

The simplest Pod pattern is a container per pod, where the single container represents an entire application. 

**Deployment**

Deployment provides declarative updates for Pods and ReplicaSets.

To deploy an application you need to create a Deployment object with the image.

```

$ kubectl create deployment app-dep --image=user/app

```
**Declarative configuration**

The following is an example of a Deployment using declarative configuration deployment.yaml file.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-dep
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: hashgenerator
          image: user/app:tag
```

Apply the deployment with apply command.

```

$ kubectl apply -f manifests/deployment.yaml

```
Note applying new deployment won't update the application unless the tag is updated. 

By using tags (e.g. user/app:tag) with the deployments each time we update the image.

```

$ docker build -t <image>:<tag>

```

Then edit deployment.yaml so that the tag is updated to the <tag> value.

**Service**

Service resource takes care of serving the application to connections from outside of the cluster.

Create a file service.yaml into the manifests folder and define which port to listen to, the port where the request should be directed to and declare the application where the request should be directed to.

```
apiVersion: v1
kind: Service
metadata:
  name: hashresponse-svc
spec:
  type: NodePort
  selector:
    app: hashresponse
  ports:
    - name: http
      nodePort: 30080
      protocol: TCP
      port: 1234
      targetPort: 3000

```

**Ingress**

Incoming Network Access resource Ingress is a completely different type of resource from Services.

In the case, that we don't have a load balancer available then we can use the Ingress, because LoadBalancer service works only with cloud providers.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-svc
            port:
              number: 2345

```

**Networking between pods**

Pods are automatically assigned unique IP addresses.

**Namespaces**

Namespaces are used to keep resources separated. 

A company which uses a cluster but has multiple projects can use namespaces to split the cluster into virtual clusters.

**Labels**

Labels are used to separate an application from others inside a namespace and to group different resources together.

**Secrets**

Secrets use base64 encoding to avoid having to deal with special characters.

```
apiVersion: v1
kind: Secret
metadata:
  name: app-key
data:
  API_KEY: c2VjcmV0Cg==

```
**Google Kubernetes Engine**

Google Kubernetes Engine (GKE) provides a managed environment for deploying, managing, and scaling your containerized applications using Google Cloud services.

GKE accepts Docker images as the application deployment format. 

A load balancer service asks for Google services to provision us a load balancer. 

**Docker Hub**

Docker Hub is service for finding and sharing container images. 

During the deployment of an application to a Kubernetes cluster, youwant one or more images to be pulled from a Docker registry.

**Update, deployment and release strategies**

Both of Rolling update and Canary release strategies are designed to make sure that the application works during and after an update.

Rather than updating every pod at the same time the idea is to update the pods one at a time and confirm that the application works.

By default Kubernetes initiates a "rolling update" when we change the image that every pod is updated sequentially.

Canary release is the term used to describe a release strategy in which we introduce a subset of the users to a new version of the application.

**Messaging Systems**

Inter-Service communication can be implemented in an asynchronous manner using an event-based publish-subscribe model or a request-reply model.

Message Queues are a method for communication between services.

NATS services are provided by one or more NATS server processes that are configured to interconnect with each other and provide a NATS service infrastructure.

NATS makes it easy for applications to communicate by sending and receiving messages. 

Data is encoded and framed as a message and sent by a publisher. The message is received, decoded, and processed by one or more subscribers.

To connect a NATS client application with a NATS service, and then subscribe or publish messages to subjects, it only needs to be configured with URL and Authentication.

![alt text](https://github.com/jylhakos/DevOpsWithKubernetes/blob/main/kubernetes.png?raw=true)

