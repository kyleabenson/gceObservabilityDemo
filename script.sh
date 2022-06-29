#!/bin/bash
# This script installes httpd on the system, then adds the Cloud Ops agent
sudo yum update -y
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
sudo yum install git ansible-core -y

git clone https://github.com/kyleabenson/gceObservabilityDemo.git
pushd gceObservabilityDemo
ansible-galaxy install googlecloudplatform.google_cloud_ops_agents -p .
ansible-playbook playbook.yaml -i 

NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')
cat <<EOF > /var/www/html/index.html
<pre>
Name: $NAME
IP: $IP
Metadata: $METADATA
</pre>
EOF


