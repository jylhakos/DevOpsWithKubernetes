Docker Hub

Create your Docker Hub repository

Sign in to Docker Hub.

https://hub.docker.com/

Build and push a container image to Docker Hub from your computer.

DOCKER EXEC SHELL

$ docker exec -it <CONTAINER-ID> bash

k8s

https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

How to install kubectl?

$ stable=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

$ curl -LO https://storage.googleapis.com/kubernetes-release/release/${stable}/bin/linux/amd64/kubectl

$ chmod +x ./kubectl

$ sudo mv ./kubectl /usr/local/bin/kubectl

kubectl

$ kubectl cluster-info

What is k3d?

k3d is a lightweight wrapper to run k3s in Docker.

k3d

$ k3d cluster create -a 2

Installing kubelet kubeadm kubectl

$ docker stop $(docker ps -a -q)

$ docker rm $(docker ps -a -q)

$ docker rmi $(docker images -q)

$ sudo ufw allow 6443/tcp

$ sudo ufw allow 2379/tcp

$ sudo ufw allow 2380/tcp

$ sudo ufw allow  10248/tcp

$ sudo ufw allow 10250/tcp

$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

$ sudo nano /etc/apt/sources.list.d/kubernetes.list

$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

$ sudo apt-get update

$ sudo apt-get install -y kubelet kubeadm kubectl

$ sudo apt-mark hold kubelet kubeadm kubectl

$ sudo swapoff -a

$ sudo sed -i '/ swap / s/^/#/' /etc/fstab

$ docker info | grep -i cgroup

$ sudo chmod a+rwx /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

$ sudo echo 'Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

$ cd /etc/systemd/system/kubelet.service.d

$ sudo nano 10-kubeadm.conf 

[Service]
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"

$ sudo chmod a+rx /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

$ cd /etc/systemd/system/kubelet.service.d

$ sudo touch 20-allow-swap.conf

$ sudo chmod a+rx 20-allow-swap.conf

$ sudo nano 20-allow-swap.conf

[Service] 
Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false”

$ sudo chmod a+rx 20-allow-swap.conf

$ sudo nano /etc/docker/daemon.json

$ cat /etc/docker/daemon.json
{
    "dns": ["192.168.31.1", "10.0.0.2", "8.8.8.8"],
    "exec-opts": ["native.cgroupdriver=systemd"]
}

$ sudo systemctl daemon-reload

$ sudo systemctl restart docker

$ sudo systemctl status docker.service

$ sudo kubeadm reset

$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16

$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

$ sudo chown $(id -u):$(id -g) /etc/kubernetes/admin.conf

$ export KUBECONFIG=$HOME/.kube/config

$ echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc

$ echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.profile

$ sudo nano ~/.bashrc

$ source ~/.bashrc

$ sudo systemctl status kubelet

$ sudo kubectl version

$ sudo kubectl cluster-info

$ sudo chown -R $USER $HOME/.kube

$ netstat -pnlt | grep 6443


