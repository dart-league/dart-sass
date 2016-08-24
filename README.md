[![Build Status](https://drone.io/bitbucket.org/evidentsolutions/dart-sass/status.png)](https://drone.io/bitbucket.org/evidentsolutions/dart-sass/latest)

## Sass integration for pub

[Sass](http://sass-lang.com/)-transformer for [pub-serve](http://pub.dartlang.org/doc/pub-serve.html) and
[pub-build](http://pub.dartlang.org/doc/pub-build.html).

## Usage

1\. Install [Sass](http://sass-lang.com/) and add it to your path.

2\. Add the following lines to your `pubspec.yaml`:

```yaml
dependencies:
  sass: any
transformers:
  - sass
```

After adding the transformer, all your `.sass` and `.scss` files that doesn't begin with `_` will be automatically transformed to
corresponding `.css` files.

If your main file imports other files outside the main files folder, you need to add the option `include_paths`,
 to let `sass` know which folder will be used for processing outside imports:

```yaml
dependencies:
  sass: any
transformers:
  - sass:
      include_paths: path/to/folder/with/other/scss
```

you can have multiple `include_paths`:

```yaml
dependencies:
  sass: any
transformers:
  - sass:
      include_paths:
        - path/to/folder/with/other/scss1
        - path/to/folder/with/other/scss2
```

If the project is going to be used as a library for third users/consumers it's highly recommended to add the
package path in the `include_paths`. For example package [ng_bootstrap](https://pub.dartlang.org/packages/ng_bootstrap)
requires package [bootstrap_sass](https://pub.dartlang.org/packages/bootstrap_sass). In that case it is needed that
`bootstrap_sass` adds the `include_paths` as fallows:

```yaml
name: bootstra_sass
...
transformers:
- sass:
    include_paths: packages/bootstrap_sass/scss
```

> By using `pub serve` during development, css files are going to live in memory only.
 Executing `pub build` creates actual css files in build folder

3\. Finally in the html files you only need to import the generated css files:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="stylesheet" href="path/to/main.css">
</head>
<body>
    <!-- content goes hear -->
</body>
</html>
```

## Configuration

You can also pass options to Sass if necessary:

```yaml
transformers:
  - sass:
      executable: /path/to/sass     # Sass executable to use
      compass: true                 # Include compass
      line_numbers: true            # Include line numbers in output
      style: compact                # Style of generated CSS
      copy_sources: true            # Copy original .scss/.sass files to output directory
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

## Current limitations

- UTF8-encoding is assumed for all input files.
