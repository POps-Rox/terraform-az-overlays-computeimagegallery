mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing"
      name     = "rg-existing"
      location = "eastus"
    }
  }

  mock_resource "azurerm_shared_image_gallery" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Compute/galleries/generated_sig"
    }
  }
}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "generated_sig"
    }
  }
}

mock_provider "azapi" {}

override_module {
  target = module.mod_azregions
  outputs = {
    location_cli   = "eastus"
    location_short = "eus"
  }
}

override_module {
  target = module.mod_scaffold_rg
  outputs = {
    resource_group_name     = "rg-created"
    resource_group_location = "westus2"
  }
}

variables {
  location                     = "eastus"
  environment                  = "public"
  deploy_environment           = "dev"
  workload_name                = "gallery"
  org_name                     = "contoso"
  existing_resource_group_name = "rg-existing"
}

run "custom_gallery_name_overrides_generated_name" {
  command = plan

  variables {
    custom_compute_image_gallery_name = "custom_sig"
  }

  assert {
    condition     = azurerm_shared_image_gallery.compute_image_gallery.name == "custom_sig"
    error_message = "custom_compute_image_gallery_name must take precedence over the generated name."
  }
}

run "empty_custom_gallery_name_falls_through_to_generated_name" {
  command = plan

  variables {
    custom_compute_image_gallery_name = ""
  }

  assert {
    condition     = azurerm_shared_image_gallery.compute_image_gallery.name == "generated_sig"
    error_message = "An empty custom_compute_image_gallery_name must fall through to the generated name."
  }
}

run "existing_resource_group_branch_is_used_by_default" {
  command = plan

  assert {
    condition     = length(data.azurerm_resource_group.rg) == 1 && length(module.mod_scaffold_rg) == 0
    error_message = "The default create_gallery_resource_group=false path must read the existing resource group and not create one."
  }

  assert {
    condition     = azurerm_shared_image_gallery.compute_image_gallery.resource_group_name == "rg-existing" && azurerm_shared_image_gallery.compute_image_gallery.location == "eastus"
    error_message = "Gallery resource group and location must pass through from the existing resource group lookup."
  }
}

run "created_resource_group_branch_is_used_when_enabled" {
  command = plan

  variables {
    create_gallery_resource_group = true
  }

  assert {
    condition     = length(data.azurerm_resource_group.rg) == 0 && length(module.mod_scaffold_rg) == 1
    error_message = "create_gallery_resource_group=true must create one scaffold resource group and skip the existing RG data lookup."
  }

  assert {
    condition     = azurerm_shared_image_gallery.compute_image_gallery.resource_group_name == "rg-created" && azurerm_shared_image_gallery.compute_image_gallery.location == "westus2"
    error_message = "Gallery resource group and location must pass through from the scaffold resource group module."
  }
}

run "image_definitions_are_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_shared_image.compute_image) == 0
    error_message = "No shared image definitions should be planned when compute_images_definitions is empty."
  }
}

run "image_definitions_are_created_when_supplied" {
  command = plan

  variables {
    compute_images_definitions = [
      {
        name = "debian12"
        identifier = {
          offer     = "Debian"
          publisher = "Debian"
          sku       = "12"
        }
        os_type = "Linux"
        tags = {
          image = "debian"
        }
      }
    ]
  }

  assert {
    condition     = length(azurerm_shared_image.compute_image) == 1 && azurerm_shared_image.compute_image["debian12"].name == "debian12"
    error_message = "Supplying one compute image definition must plan exactly one matching shared image."
  }

  assert {
    condition     = azurerm_shared_image.compute_image["debian12"].location == "eastus" && azurerm_shared_image.compute_image["debian12"].resource_group_name == "rg-existing"
    error_message = "Shared images must inherit the resolved location and resource group."
  }
}

run "default_and_caller_tags_are_merged_on_gallery" {
  command = plan

  variables {
    add_tags = {
      workload   = "caller-workload"
      costCenter = "1234"
    }
  }

  assert {
    condition     = azurerm_shared_image_gallery.compute_image_gallery.tags["deployedBy"] == "AzureNoOpsTF [default]" && azurerm_shared_image_gallery.compute_image_gallery.tags["env"] == "public"
    error_message = "Default tags must include deployedBy and env values."
  }

  assert {
    condition     = azurerm_shared_image_gallery.compute_image_gallery.tags["workload"] == "caller-workload" && azurerm_shared_image_gallery.compute_image_gallery.tags["costCenter"] == "1234"
    error_message = "Caller add_tags must merge into and be able to override gallery default tags."
  }
}

run "community_gallery_sharing_is_enabled_when_requested" {
  command = plan

  variables {
    enable_community_gallery = true
    compute_gallery = {
      permission      = "Community"
      eula            = "https://contoso.example/eula"
      prefix          = "contoso"
      publisher_email = "publisher@contoso.example"
      publisher_uri   = "https://contoso.example"
    }
  }

  assert {
    condition     = length(azurerm_shared_image_gallery.compute_image_gallery.sharing) == 1
    error_message = "Enabling community gallery sharing with compute_gallery settings must plan one community sharing block."
  }

  assert {
    condition     = azurerm_shared_image_gallery.compute_image_gallery.sharing[0].community_gallery[0].prefix == "contoso"
    error_message = "Community gallery settings must be read from the compute_gallery object."
  }
}
