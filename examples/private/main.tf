module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

module "secrets_manager" {
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "1.20.0"
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = "${var.prefix}-secrets-manager"
  sm_service_plan      = "trial"
  allowed_network      = "private-only"
  endpoint_type        = "private"
  sm_tags              = var.resource_tags
}

module "private_secret_engine" {
  source                    = "../.."
  secrets_manager_guid      = module.secrets_manager.secrets_manager_guid
  region                    = var.region
  root_ca_name              = var.root_ca_name
  root_ca_common_name       = "*.cloud.ibm.com"
  root_ca_max_ttl           = "8760h"
  intermediate_ca_name      = var.intermediate_ca_name
  certificate_template_name = var.certificate_template_name
  endpoint_type             = "private"
}
