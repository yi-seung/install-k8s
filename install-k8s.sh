#!/usr/bin/env bash
echo "####################################################################################################"
echo "##### KUBERNETES 설치 #####"
sudo setenforce 0 # SELinux 끄기
sudo swapoff -a && free -m
echo "####################################################################################################"
echo "##### KUBERNETES 설치 #####"
if [ -f  /etc/yum.repos.d/kubernetes.repo ]; then
	sudo cp -p /etc/yum.repos.d/kubernetes.repo /etc/yum.repos.d/kubernetes.repo-"$(date +%F_%R)"
fi
sudo cp ./kubernetes.repo /etc/yum.repos.d/
echo "####################################################################################################"
sudo yum update -y
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
echo "##### KUBERNETES 설치 #####"
sudo systemctl enable kubelet && sudo systemctl start kubelet; sudo systemctl status kubelet
cat <<EOF >  ./k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
if test -e /etc/sysctl.d/k8s.conf  # 기존 파일이 있으면 백업
    then sudo cp -p /etc/sysctl.d/k8s.conf /etc/sysctl.d/k8s.conf-"$(date +%F_%R)" # 중복실행시 덮어쓰지 않도록
fi
sudo cp ./k8s.conf /etc/sysctl.d/k8s.conf
sudo echo 1 |sudo tee -a /proc/sys/net/ipv4/ip_forward
sudo swapoff -a && free -m
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo kubeadm reset -f
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
echo "####################################################################################################"

