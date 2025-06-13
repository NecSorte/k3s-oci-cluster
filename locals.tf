locals {
  public_lb_ip = [for interface in oci_network_load_balancer_network_load_balancer.k3s_public_lb.ip_addresses : interface.ip_address if interface.is_public == true]

  inventory = templatefile("${path.module}/templates/inventory.tpl", {
    k3s_servers_private = data.oci_core_instance.k3s_servers_instances_ips.*.private_ip
    k3s_workers_private = data.oci_core_instance.k3s_workers_instances_ips.*.private_ip
    lb_private_ip       = oci_network_load_balancer_network_load_balancer.k3s_public_lb.ip_addresses[0].ip_address
    bastion_ip          = oci_core_instance.bastion.public_ip
    ssh_priv_key_path   = pathexpand("~/.ssh/k3s-ansible.pem")
  })
}

# ---- write-out, minimal exposure -----------------------------------------
resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible/inventory.ini"
  content         = local.inventory
  file_permission = "0600" # chmod 600
  sensitive       = true   # terraform plan hides the diff
}