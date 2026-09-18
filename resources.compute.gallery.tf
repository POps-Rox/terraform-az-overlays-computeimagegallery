# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------------
# Azure Compute Image Gallery - Default is "false"
#---------------------------------------------------------------

resource "azurerm_shared_image_gallery" "compute_image_gallery" {
  name = local.compute_image_gallery_name

  location            = local.location
  resource_group_name = local.resource_group_name
  description         = var.compute_image_gallery_description

  dynamic "sharing" {
    for_each = var.compute_gallery[*]
    content {
      permission = var.enable_community_gallery ? "Community" : sharing.value.permission

      dynamic "community_gallery" {
        for_each = var.enable_community_gallery ? [sharing.value] : []
        content {
          eula            = community_gallery.value.eula
          prefix          = community_gallery.value.prefix
          publisher_email = community_gallery.value.publisher_email
          publisher_uri   = community_gallery.value.publisher_uri
        }
      }
    }
  }

  tags = merge(local.default_tags, var.add_tags)
}
