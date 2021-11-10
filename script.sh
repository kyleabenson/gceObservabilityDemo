#!/bin/bash
# This script installes httpd on the system, then adds the Cloud Ops agent
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo systemctl start apache2

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
