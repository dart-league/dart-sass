## The name of this package was changed from 
`sass` to `dart_sass_transformer`



[![Build Status](https://drone.io/bitbucket.org/evidentsolutions/dart-sass/status.png)](https://drone.io/bitbucket.org/evidentsolutions/dart-sass/latest)

## Sass integration for pub

[Sass](http://sass-lang.com/)-transformer for [pub-serve](http://pub.dartlang.org/doc/pub-serve.html) and
[pub-build](http://pub.dartlang.org/doc/pub-build.html).

## Usage

Simply add the following lines to your `pubspec.yaml`:

```yaml
dependencies:
  sass: any
transformers:
  - sass
```

After adding the transformer your `.sass` and `.scss` files will be automatically transformed to
corresponding `.css` files.

You need to have [Sass](http://sass-lang.com/) installed and available on the path.

## Configuration

You can also pass options to Sass if necessary:

```yaml
transformers:
  - sass:
      executable: /path/to/sass     # Sass executable to use
      compass: true                 # Include compass
      line-numbers: true            # Include line numbers in output
      style: compact                # Style of generated CSS
      copy-sources: true            # Copy original .scss/.sass files to output directory
```

## Using SassC

You can use [SassC](https://github.com/hcatlin/sassc) instead of normal Sass by specifying executable
as 'sassc' (or any path ending with 'sassc'):

```yaml
transformers:
  - sass:
      executable: sassc  # or /path/to/sassc
```

SassC only supports `.scss`-files and does not support Compass.

## Inlined transformer

Normally the transformer simply asks Sass to process the primary input files and Sass will then
read the dependent inputs from file system. However, if the input files for Sass are themselves
produced by other transformers, they might not exist on the file system at all. The normal
transformer will not work in those cases.

To work around this problem, you can use `inlined_sass_transformer`. It will use Barback's APIs
to read and inline all imports into one big Sass file which it will then pass to Sass. 
The downside  is that line numbers on error messages and source maps might be incorrect. (See 
[Issue #4](https://bitbucket.org/evidentsolutions/dart-sass/issue/4/support-transformations-to-imported-sass) 
for details.)

To enable the use of inlined transformer, use `sass/inlined_sass_transformer` as your transformer:

```yaml
transformers:
  - sass/inlined_sass_transformer
      <possible configuration settings>
```

## Current limitations

- UTF8-encoding is assumed for all input files.
