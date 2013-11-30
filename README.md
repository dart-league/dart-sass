## Sass integration for pub

[Sass](http://sass-lang.com/)-transformer for [pub-serve](http://pub.dartlang.org/doc/pub-serve.html) and
[pub-build](http://pub.dartlang.org/doc/pub-build.html).

## Usage

Simply add the following lines to your `pubspec.yaml`:

    dependencies:
      sass: any
    transformers:
      - sass

After adding the transformer your `.sass` and `.scss` files will be automatically transformed to
corresponding `.css` files.

You need to have [Sass](http://sass-lang.com/) installed and available on the path.

## Current limitations

- Imported files are not marked as dependencies. Primary files need to be modified for rebuilds.
- UTF8-encoding is assumed for all input files.
