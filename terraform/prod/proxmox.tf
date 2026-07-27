locals {
  pm_vms = {
    "shoot-o11y-01" = {
      cores           = 2
      memory          = 4096
      disk_size       = 12
      wg_address      = "10.0.0.5"
      wg_private_key  = var.wg_shoot_o11y_01_private_key
      dispatch_target = "prod-shoot-o11y-01-1"
    }
  }
}

resource "proxmox_virtual_environment_download_file" "debian_13" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
  file_name    = "debian-13-generic-amd64.img"
}

resource "proxmox_virtual_environment_file" "user_data" {
  for_each = local.pm_vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    file_name = "${local.org}-${local.env}-${each.key}-user-data.yaml"
    data = <<-EOF
      #cloud-config
      runcmd:
        - |
      ${indent(6, templatefile("${path.module}/templates/bootstrap.sh.tftpl", {
    cicd_ssh_public_key   = var.cicd_ssh_public_key
    wg_private_key        = each.value.wg_private_key
    wg_address            = each.value.wg_address
    wg_proxmox_public_key = var.wg_proxmox_public_key
    org                   = local.org
    gh_access_token       = var.gh_access_token
    dispatch_target       = each.value.dispatch_target
}))}
    EOF
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  for_each = local.pm_vms

  name      = "${local.org}-${local.env}-${each.key}"
  node_name = "pve"

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.debian_13.id
    interface    = "scsi0"
    size         = each.value.disk_size
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data[each.key].id
  }
}
