# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "shared_image_gallery" {
  description = "Azure Shared Image Gallery output object"
  value       = module.mod_compute_image_gallery.shared_image_gallery
}

output "id" {
  description = "Azure Shared Image Gallery ID"
  value       = module.mod_compute_image_gallery.shared_image_gallery.id
}

output "name" {
  description = "Azure Shared Image Gallery name"
  value       = module.mod_compute_image_gallery.shared_image_gallery.name
}

output "shared_images_definitions" {
  description = "Azure Shared Images definitions"
  value       = module.mod_compute_image_gallery.shared_image
}