resource "grafana_folder" "test_folder" {
  provider = grafana.stack
  title    = "Test Folder 1"
}
