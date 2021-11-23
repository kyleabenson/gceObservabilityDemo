#!/bin/bash
# This script installes httpd on the system, then adds the Cloud Ops agent
sudo apt-get update -y
apt-get install -y apache2 jq

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

cat <<EOF >> /etc/httpd/conf/httpd.conf
<Location "/server-status">
    SetHandler server-status
    Require host example.com
</Location>
EOF
sudo systemctl start apache2
