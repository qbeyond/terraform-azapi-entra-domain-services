# Changelog
All notable changes to this module will be documented in this file.
 
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
 
## [Unreleased] - YYYY-MM-DD

### Added

### Changed
 
### Removed
 
### Fixed

## [2.0.0] - 2024-01-15

### Removed
 
- Removed user creation from module

## [1.1.0] - 2024-01-16

### Added
 
- Added required outbound nsg rules for entra domain services
- Added deny all outbound nsg rule

## [1.0.1] - 2024-01-16
 
### Fixed

- Set Ldaps wrong false to "disabled"

## [1.0.0] - 2024-01-12

### Added
 
- Deploy ADmin Group
- Deploy Admin User as member of Admin Group
- Deploy Entra Domain Services using `azapi`, because the respurce of `azurerm` is missing features
