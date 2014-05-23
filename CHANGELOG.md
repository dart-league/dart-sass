# vX.Y.Z (yyyy-mm-dd)

- **Breaking change:** don't copy source .scss/.sass files to build directory by default.
  Use `copy-sources: true` to keep the old behavior.

# v0.2.2 (2014-05-23)

- Require Barback 0.13.x.
- Fixed `DeclaringTransformer` on Barback 0.13.x.  

# v0.2.1 (2014-05-15)

- Implemented `DeclaringTransformer` interface so Barback can optimize the asset graph.
- Compatibility with Barback 0.13.x.

# v0.2.0 (2014-05-15)

- Exclude URL-imports when parsing imports. (Thanks to Vikraman Choudhury.)

# v0.1.1 (2014-04-24)

- Ignore Compass imports when reading the dependencies of a module. (Thanks to Dan Schultz.)

# v0.1.0 (2014-04-19)

- Support using [SassC](https://github.com/hcatlin/sassc) instead of vanilla Sass.
