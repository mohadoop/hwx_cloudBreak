#!/bin/sh

yum update -y
yum -y install iptables-services net-tools

iptables --flush INPUT && \
iptables --flush FORWARD && \
service iptables save


sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum -y install docker-engine
systemctl enable docker.service
systemctl start docker

yum -y install unzip tar
curl -Ls public-repo-1.hortonworks.com/HDP/cloudbreak/cloudbreak-deployer_2.4.0_Linux_x86_64.tgz | sudo tar -xz -C /bin cbd
cbd --version

rm -rf ~/cloudbreak-deployment
mkdir ~/cloudbreak-deployment

tee ~/cloudbreak-deployment/Profile <<-'EOF'
export UAA_DEFAULT_SECRET=MySecret123
export UAA_DEFAULT_USER_PW=MySecurePassword123
export UAA_DEFAULT_USER_EMAIL=dbialek@hortonworks.com
export PRIVATE_IP=`hostname -i`
EOF



rm ~/cloudbreak-deployment/*.yml
cd ~/cloudbreak-deployment
cbd generate
cbd pull
cbd start