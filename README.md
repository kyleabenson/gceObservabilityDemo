# GCE Observability Demo

This is demo contains the following:

Infra
* A GCP network load balancer
* A 3 GCE system frontend application (apache)
<!-- * A 'backend' of objects stored in a GCP Storage bucket -->

Monitoring
* Cloud Ops Agent deployed to GCE systems configured for Apache metrics & logs
* Application specific dashboard


All objects are deployable via Terraform

This demo uses [User Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default) and thus assumes it is being deployed from within Google Cloud or on an end user environment that is authenticated with `gcloud`
