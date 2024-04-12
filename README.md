# Module
[![GitHub tag](https://img.shields.io/github/tag/qbeyond/terraform-azurerm-entra-domain-services.svg)](https://registry.terraform.io/modules/qbeyond/entra-domain-services/azurerm/latest)
[![License](https://img.shields.io/github/license/qbeyond/terraform-azurerm-entra-domain-services.svg)](https://github.com/qbeyond/terraform-azurerm-entra-domain-services/blob/main/LICENSE)

----

Module to deploy entra domain services (former Azure Active Directory Domain Services). This module will create an entra domain services, a service principal 'Domain Services', a group AADC Administratos in Entra ID and an administrative account in that group.

<!-- BEGIN_TF_DOCS -->
## Usage

It's very easy to use!
```hcl
provider "azurerm" {
  features {

  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.7.0 |

## Inputs

No inputs.
## Outputs

No outputs.
## Resource types

          No resources.
      
    
## Modules

No modules.
## Resources by Files

            No resources.
        
    
<!-- END_TF_DOCS -->

## Contribute

Please use Pull requests to contribute.

When a new Feature or Fix is ready to be released, create a new Github release and adhere to [Semantic Versioning 2.0.0](https://semver.org/lang/de/spec/v2.0.0.html).