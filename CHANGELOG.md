# Changelog

# v2.0.0 - Phase 1: azurerm Provider Upgrade

## Breaking Changes
- **Provider version:** Upgraded `azurerm` provider from `~> 3.116` to `~> 4.20`
- **Terraform version:** Minimum Terraform version increased from `>= 1.9` to `>= 1.10`

## Added
- Added `azapi` provider `~> 2.0` dependency for fleet alignment

## Changed
- Updated `private_endpoint_network_policies_enabled` (bool) to `private_endpoint_network_policies` (string enum) in template file:
  - `true` → `"Enabled"`
  - `false` → `"Disabled"`

## Notes
- All resources (`azurerm_shared_image_gallery`, `azurerm_shared_image`, `azurerm_shared_image_version`) are stable in 4.x
- No mechanical attribute renames required for Compute Gallery resources
- Template private endpoint subnet configuration updated for 4.x compatibility

# v1.0.0 - 02/03/2024

Added
- Init Source

