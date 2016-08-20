# v0.5.0 (2016-08-20)

- Convert `SassTransformer` into aggregate transformer, this reduce the complexity of the code and avoid wrongly parsing `@import` inside comments (fixes #6)
- Removed unneeded files
  * `base_sass_transformer.dart` 
  * `sass_file.dart`
  * `inlined_sass_file.dart`
  * `inlined_sass_transformer.dart`
  * `run.sh`
  * `inlined_sass_transformer_test.dart`
  * `sass_file_test.dart`

# v0.4.2 (2014-11-03)

- Fixed files over 1024 bytes getting truncated on Windows. ([#19](https://bitbucket.org/evidentsolutions/dart-sass/issue/19/sass-transformer-produces-zero-length)) (Thanks to Alexander Sergeev.)
- Normalize the load paths to platform's native format. (Thanks to llamadonica.)

# v0.4.1 (2014-10-09)

- Filter out external packages when resolving imports. ([#12](https://bitbucket.org/evidentsolutions/dart-sass/issue/12/problem-when-trying-to-create-a-library-of)) (Thanks to Konstantin Borisov.)

# v0.4.0 (2014-09-22)

- Support for new `inlined_sass_transformer`. ([#4](https://bitbucket.org/evidentsolutions/dart-sass/issue/4/support-transformations-to-imported-sass)) (Thanks to Dan Schultz.) 
- Require Barback 0.15.x.

# v0.3.2 (2014-09-17)

- Support Barback 0.15.x. 

# v0.3.1 (2014-06-24)

- Use `sass.bat` as default executable on Windows. ([#10](https://bitbucket.org/evidentsolutions/dart-sass/issue/10/add-windows-default-executable-support)) (Thanks to Nicholas Tuck.)

# v0.3.0 (2014-05-25)

- **Breaking change:** don't copy source .scss/.sass files to build directory by default.
  Use `copy-sources: true` to keep the old behavior. ([#7](https://bitbucket.org/evidentsolutions/dart-sass/issue/7/option-to-not-copy-the-scss-source-to))
- Support imports with directory names. ([#8](https://bitbucket.org/evidentsolutions/dart-sass/issue/8/build-fails-when-import-references-a-file]))

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
