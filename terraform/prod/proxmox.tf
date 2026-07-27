locals {
  pm_defaults = {
    node_name         = "proxmox"
    bridge            = "vmbr0"
    nic_model         = "virtio"
    disk_datastore    = "local-lvm"
    snippet_datastore = "local"
    cores             = 2
    memory            = 4096
    disk_size         = 15
  }

  pm_vms = {
    "shoot-o11y-01" = {
      dispatch_target = "prod-shoot-o11y-01-1"
      wg_address      = "10.0.0.5"
      wg_private_key  = var.wg_shoot_o11y_01_private_key
      cores           = 6
      memory          = 8192
      disk_size       = 30
    }
  }

  pm_user_data = {
    for name, cfg in local.pm_vms : name => <<-EOF
      #cloud-config
      runcmd:
        - |
      ${indent(6, templatefile("${path.module}/templates/bootstrap.sh.tftpl", {
    cicd_ssh_public_key   = var.cicd_ssh_public_key
    wg_private_key        = cfg.wg_private_key
    wg_address            = cfg.wg_address
    wg_proxmox_public_key = var.wg_proxmox_public_key
    org                   = local.org
    gh_access_token       = var.gh_access_token
    dispatch_target       = cfg.dispatch_target
    }))}
    EOF
  }
}

resource "proxmox_download_file" "debian_13" {
  content_type = "import"
  datastore_id = local.pm_defaults.snippet_datastore
  node_name    = local.pm_defaults.node_name
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  file_name    = "debian-13-generic-amd64.qcow2"
}

resource "proxmox_virtual_environment_file" "user_data" {
  for_each = local.pm_vms

  content_type = "snippets"
  datastore_id = try(each.value.snippet_datastore, local.pm_defaults.snippet_datastore)
  node_name    = try(each.value.node_name, local.pm_defaults.node_name)

  source_raw {
    file_name = "${local.org}-${local.env}-${each.key}-user-data-${substr(sha256(local.pm_user_data[each.key]), 0, 12)}.yaml"
    data      = local.pm_user_data[each.key]
  }
}

resource "terraform_data" "user_data_hash" {
  for_each = local.pm_vms

  input = sha256(local.pm_user_data[each.key])
}

resource "proxmox_virtual_environment_vm" "this" {
  for_each = local.pm_vms

  name      = "${local.org}-${local.env}-${each.key}"
  node_name = try(each.value.node_name, local.pm_defaults.node_name)

  stop_on_destroy = true

  agent {
    enabled = false
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  cpu {
    cores = try(each.value.cores, local.pm_defaults.cores)
  }

  memory {
    dedicated = try(each.value.memory, local.pm_defaults.memory)
  }

  disk {
    datastore_id = try(each.value.disk_datastore, local.pm_defaults.disk_datastore)
    import_from  = proxmox_download_file.debian_13.id
    interface    = "scsi0"
    size         = try(each.value.disk_size, local.pm_defaults.disk_size)
  }

  network_device {
    bridge = try(each.value.bridge, local.pm_defaults.bridge)
    model  = try(each.value.nic_model, local.pm_defaults.nic_model)
  }

  initialization {
    datastore_id = try(each.value.disk_datastore, local.pm_defaults.disk_datastore)

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data[each.key].id
  }

  lifecycle {
    replace_triggered_by = [
      terraform_data.user_data_hash[each.key],
    ]
  }
}
