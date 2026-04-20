# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Azure NoOps Naming - This should be used on all resource naming
#------------------------------------------------------------
data "popsrox_utils_resource_name" "shared_image_gallery" {
  name          = var.workload_name
  resource_type = "azurerm_shared_image_gallery"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.environment, local.name_suffix, var.use_naming ? "sig" : local.anoa_slug])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
