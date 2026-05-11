# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_compute_image_gallery" {
  #source  = "github.com/POps-Rox/terraform-az-overlays-computeimagegallery"
  #version = "x.x.x"
  source = "../../.."

  # Resource Group, location details
  create_gallery_resource_group = true
  location                      = var.location
  deploy_environment            = var.deploy_environment
  environment                   = var.environment
  org_name                      = var.org_name
  workload_name                 = "gallery"

  # Azure Compute Image Gallery
  compute_images_definitions = [
    {
      name = "Debian11"
      identifier = {
        offer     = "Debian"
        publisher = "Claranet"
        sku       = "11"
      }
      os_type     = "Linux"
      description = "Claranet's Debian 11 custom image."
    },
    {
      name = "Debian12"
      identifier = {
        offer     = "Debian"
        publisher = "Claranet"
        sku       = "12"
      }
      os_type     = "Linux"
      description = "Claranet's Debian 12 custom image."
    },
  ]

  add_tags = {
    example = "compute_gallery_new_rg"
  }
}
