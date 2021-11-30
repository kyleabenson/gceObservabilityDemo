///
/// Create Logging and Monitoring Components
///

data "http" "nginx_dash" {
  url = "https://cloud-monitoring-dashboards.googleusercontent.com/samples/nginx/overview.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

resource "google_monitoring_dashboard" "nginx_dashboard" {
  dashboard_json = data.http.nginx_dash.body
}

data "local_file" "apache" {
  filename = "${path.module}/dashboards/custom_httpd_dash.json"
}

resource "google_monitoring_dashboard" "apache_dashboard" {
  dashboard_json = data.local_file.apache.content
}
// Create Custom Dashboard

///Create Alert 