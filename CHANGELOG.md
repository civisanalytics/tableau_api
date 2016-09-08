# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
- `TableauApi::Resources::Groups` added to support API calls for adding/deleting/updating groups.
- `TableauApi::Resources::Workbook#permissions` now supports group permissions.
- `TableauApi::Resources::Workbook#remove_permissions` added, including support for user and group permissions.
- `TableauApi::Connection#api_delete?` added, to support permission removal
- `TableauApi::Client#respond_to_missing?` added, per best practices and new rubocop

## [1.0.0] - 2016-06-06
### Added
- Initial Release

[Unreleased]: https://github.com/civisanalytics/tableau_api/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/civisanalytics/tableau_api/tree/v1.0.0
