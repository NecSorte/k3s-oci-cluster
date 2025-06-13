resource "oci_core_default_security_list" "default_security_list" {
  compartment_id             = var.compartment_ocid
  manage_default_resource_id = oci_core_vcn.default_oci_core_vcn.default_security_list_id

  display_name = "Default security list"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = 1 # icmp
    source   = var.my_public_ip_cidr

    description = "Allow icmp from  ${var.my_public_ip_cidr}"

  }

  ingress_security_rules {
    protocol = 6 # tcp
    source   = var.my_public_ip_cidr

    description = "Allow SSH from ${var.my_public_ip_cidr}"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.oci_core_vcn_cidr

    description = "Allow all from vcn subnet"
  }

  freeform_tags = {
    "provisioner"           = "terraform"
    "environment"           = "${var.environment}"
    "${var.unique_tag_key}" = "${var.unique_tag_value}"
  }
}

module "cloud_guard" {
  source              = "oci-landing-zones/security/cloud-guard"   # registry.terraform.io
  tenancy_ocid        = var.tenancy_ocid
  configuration_mode  = "READ_ONLY"   # flip to DETECT/REMEDIATE when ready
  reporting_region    = var.region
}

module "security_zones" {
  source           = "oci-landing-zones/security/security-zones"
  compartment_ocid = var.root_compartment_ocid
  recipe           = "CIS_Level_1"
}

resource "oci_bastion_session" "ssh_sessions" {
  for_each = toset(var.target_instance_ids) # List of OCIDs

  bastion_id             = oci_bastion_bastion.bastion.id
  session_ttl_in_seconds = 10800
  display_name           = "ssh-session-${each.key}"
  key_type               = "SSH"
  target_resource_id     = each.value
  target_resource_port   = 22
  target_resource_operating_system_user_name = "opc"

  metadata = {
    "ssh_public_key" = file(var.ssh_public_key_path)
  }

  freeform_tags = {
    environment = var.environment
  }
}