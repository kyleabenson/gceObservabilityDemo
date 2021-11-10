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


////
resource "google_compute_instance_template" "default" {
  name        = "appserver-template"
  description = "This template is used to create app server instances."

  tags = ["foo", "bar"]

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
  
  tags = ["http-server"]


}

data "google_compute_image" "my_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

resource "google_compute_disk" "foobar" {
  name  = "existing-disk"
  image = data.google_compute_image.my_image.self_link
  size  = 10
  type  = "pd-ssd"
  zone  = "us-central1-a"
}

resource "google_project_services" "project_services" {
  services   = var.api_endpoints
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

variable "api_endpoints" {
  description = "List of API endpoints that must be enabled to use the cloud ops agent"
  type        = list(string)
  default     = ["monitoring.googleapis.com", "logging.googleapis.com", "osconfig.googleapis.com"]
}

variable "gcp_project" {
  description = "The GCP project to be used for this deployment"
  type        = string
}

variable "gcp_region" {
  description = "The region used for this deployment"
  type        = string
  default     = "us-central1"
}
