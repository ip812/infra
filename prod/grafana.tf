resource "grafana_folder" "test_folder" {
  provider = grafana.stack
  title    = "Test Folder 1"
}

resource "grafana_folder" "foo_folder" {
  provider = grafana.stack
  title    = "Foo Folder 1"
}
