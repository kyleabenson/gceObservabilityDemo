# Copyright 2021 Google LLC

#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at

#         https://www.apache.org/licenses/LICENSE-2.0

#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.


// Configure the Google Cloud provider
provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
}

// Data resources
data "google_compute_default_service_account" "default" {
}

// Variable Definitions 
variable "gcp_project" {
  description = "The GCP project to be used for this deployment"
  type        = string
}

variable "gcp_region" {
  description = "The region used for this deployment"
  type        = string
  default     = "us-central1"
}

//// Resource definitions
resource "google_compute_instance_template" "default" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."

  tags = ["foo", "bar", "http-server"]

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image      = "debian-cloud/debian-9"
    auto_delete       = true
    boot              = true
  }

  metadata_startup_script = file("${path.module}/script.sh")
  
  network_interface {
    network = "default"

    access_config {
     // Include this section to give the VM an external ip address
   }
  }

  lifecycle {
    create_before_destroy = true
  }
  
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

}

data "google_compute_image" "my_image" {
  family  = "debian-9"
  project = "debian-cloud"
}


resource "google_project_service" "monitoring_service" {
  service   = "monitoring.googleapis.com"
}
resource "google_project_service" "logging_service" {
  service   = "logging.googleapis.com"
}
resource "google_project_service" "osconfig_service" {
  service   = "osconfig.googleapis.com"
}

resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  name               = "instance-group-manager"
  base_instance_name = "instance-group-manager"
  target_size        = "3"
  version {
    name = "test"
    instance_template  = google_compute_instance_template.default.id
  }
}


resource "google_project_iam_binding" "monitoring_policy_binding" {
  project = var.gcp_project
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${data.google_compute_default_service_account.default.email}"
  ]
}

resource "google_project_iam_binding" "logging_policy_binding" {
  project = var.gcp_project
  role    = "roles/logging.logWriter"

  members = [
    "serviceAccount:${data.google_compute_default_service_account.default.email}"
  ]
}

resource "google_project_iam_binding" "osconfig_policy_binding" {
  project = var.gcp_project
  role    = "roles/osconfig.guestPolicyViewer"

  members = [
    "serviceAccount:${data.google_compute_default_service_account.default.email}"
  ]
}

resource "google_compute_project_metadata" "default" {
  metadata = {
    enable-guest-attributes  = "TRUE"
    enable-osconfig = "TRUE"
  }
}



