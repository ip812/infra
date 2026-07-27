locals {
  # Per-VM Proxmox settings. Only what differs per node lives here; disk/cpu/mem
  # defaults are literals in the proxmox_vm_qemu resource below.
  pm_vms = {
    "o11y-01" = {
      wg_address      = "10.0.0.5"
      wg_private_key  = var.wg_shoot_o11y_01_private_key
      dispatch_target = "prod-shoot-o11y-01-1"
    }
  }
}

# Cloud-init user-data snippet per VM. Renders the shared bootstrap template
# (same flow as the EC2 shoot nodes): authorize the CI/CD SSH key for root,
# join WireGuard, wait for a handshake, then fire the kubeadm-init dispatch.
resource "proxmox_cloud_init_disk" "this" {
  for_each = local.pm_vms

  name     = "${local.org}-${local.env}-${each.key}"
  pve_node = "pve"
  storage  = "local"

  user_data = <<-EOF
    #cloud-config
    runcmd:
      - |
    ${indent(4, templatefile("${path.module}/templates/bootstrap.sh.tftpl", {
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

resource "proxmox_vm_qemu" "this" {
  for_each = local.pm_vms

  name        = "${local.org}-${local.env}-${each.key}"
  target_node = "pve"

  agent   = 1
  cores   = 2
  memory  = 4096
  scsihw  = "virtio-scsi-single"
  os_type = "cloud-init"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "12G"
          storage = "local-lvm"
          # Debian generic cloud image; downloaded to the node then imported.
          import_from = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr0"
    model  = "virtio"
  }

  serial {
    id   = 0
    type = "socket"
  }

  # Cloud-init: DHCP on the LAN bridge; custom user-data drives the bootstrap.
  ipconfig0 = "ip=dhcp"
  cicustom  = "user=local:${proxmox_cloud_init_disk.this[each.key].id}"

  lifecycle {
    replace_triggered_by = [
      proxmox_cloud_init_disk.this[each.key].id,
    ]
  }
}
