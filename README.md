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

After adding the transformer all your `.sass` and `.scss` files will be automatically transformed to
corresponding `.css` files.

If your main file imports other files you will need to add the option `include_paths`,
 to let `sass` know which folder will be used for processing imports:

```yaml
dependencies:
  sass: any
transformers:
  - sass:
      entry_points: path/to/main.scss
      include_paths: path/to/folder/with/other/scss
```

you can have multiple `entry_points` and multiple `include_paths`:

```yaml
dependencies:
  sass: any
transformers:
  - sass:
      entry_points:
        - path/to/main.scss
        - path/to/other.scss
        - included/*.scss       # this include all scss files inside included
        - !exlcuded/*.scss      # this exclude all scss files insde excluded
      include_paths:
        - path/to/folder/with/other/scss1
        - path/to/folder/with/other/scss2
```

> Doing `pub serve` during development, css files are going to live in memory only. When you do `pub build` actual css files will be output in build folder

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
