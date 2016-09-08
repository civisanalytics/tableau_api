# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [2.0.0] - 2016-09-08
### Added
- `groups` added to support API calls for adding/deleting/updating groups
- `workbook.add_permissions` supports group permissions
- `workbook.remove_permissions` supports group permissions.

### Broken
- `workbook.permissions` now retrieves current permissions. Use
  `workbook#add_permissions` to add permissions.

## [1.0.0] - 2016-06-06
### Added
- Initial Release

[Unreleased]: https://github.com/civisanalytics/tableau_api/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/civisanalytics/tableau_api/tree/v1.0.0
