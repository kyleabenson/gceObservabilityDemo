#!/bin/bash
for i in $(gcloud compute instances list --format="value(EXTERNAL_IP)" --filter=instance-group); do echo $i >> inventory.yaml ; done

for i in $(gcloud compute instances list --format="value(name)" --filter=instance-group); do gcloud compute ssh $i --command=true; done

ssh-agent

apt install ansible

# ansible-galaxy install googlecloudplatform.google_cloud_ops_agents -p .
# ansible -m ping all -i inventory.yaml --key-file=google_compute_engine