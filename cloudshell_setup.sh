#!/bin/bash
for i in $(gcloud compute instances list --format="value(EXTERNAL_IP)" --filter=instance-group); do echo $i >> inventory.yaml ; done

for i in $(gcloud compute instances list --format="value(name)" --filter=instance-group); do gcloud compute ssh $i --command=true; done
