#!/bin/bash

# installing docker and kind cluster

sudo apt update

#installig docker
sudo apt install docker.io -y

#starting docker
sudo systemctl start docker

#enabling docker
sudo systemctl enable docker

#checking current user
echo $USER

#adding current user to docker group
sudo usermod -aG docker $USER

#When you run newgrp docker, the command switches your current group membership to the docker group.
#This means that any subsequent commands you run in the same terminal session will be executed with the permissions and privileges of the docker group.
newgrp docker

#installing kind

#creating kind config file
cat << EOF > config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
  image: kindest/node:v1.30.0
- role: worker
  image: kindest/node:v1.30.0
- role: worker
  image: kindest/node:v1.30.0
EOF

#creating kind shell script

cat << EOF > kind-install.sh
#!/bin/bash

# For AMD64 / x86_64

[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo cp ./kind /usr/local/bin/kind
rm -rf kind
EOF

#giving execute permission to kind-install script
chmod +x kind-install.sh

#running kind-install script
./kind-install.sh

#checking kind version
echo "$(kind --version)"

#installing kubectl

cat << EOF > kubectl-install.sh
#!/bin/bash

# Variables
VERSION="v1.30.0"
URL="https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
INSTALL_DIR="/usr/local/bin"

# Download and install kubectl
curl -LO "$URL"
chmod +x kubectl
sudo mv kubectl $INSTALL_DIR/
kubectl version --client

# Clean up
rm -f kubectl

echo "kubectl installation complete."
EOF

#giving execute permission to kubectl-install script
chmod +x kubectl-install.sh

#running kubectl-install script
./kubectl-install.sh

#checking kubectl version
echo "$(kubectl version)"

#creating kind cluster 
kind create cluster --config config.yaml --name my-cluster

#checking cluster status
echo "$(kind get clusters)"
