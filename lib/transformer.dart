library sass.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:path/path.dart';
import 'package:sass/sass.dart';
import 'dart:io';

part 'package:sass/src/transformer_options.dart';

/// Transformer used by `pub build` and `pub serve` to convert Sass-files to CSS.
class SassTransformer extends AggregateTransformer {
  SassTransformer.asPlugin(BarbackSettings settings) :
        options = new TransformerOptions.parse(settings.configuration);

  final TransformerOptions options;

  // Only process assets where the extension is ".scss" or ".sass".
  classifyPrimary(AssetId id) =>
      ['.scss', '.sass'].any((e) => e == id.extension) ? id.extension : null;

  Future apply(AggregateTransform transform) async {
    var assets = await transform.primaryInputs.toList();

    return Future.wait(assets.map((asset) {
      var id = asset.id;

      // files excluded of entry_points are not processed
      // if user don't specify entry_points, the default value is all '*.sass' and '*.html' files
      if (basename(id.path).startsWith('_')) {
        // if asset is not an entry point it wild be consumed
        // (this is to no output scss files in build folder)
        return new Future(() => transform.consumePrimary(id));
      }

      return transform.readInputAsString(id).then((content) {
        print('[dart-sass] processing: ${id}');
        //TODO: add support for no-symlinks packages
        options.includePaths.add(dirname(id.path).replaceFirst('lib/', 'packages/${id.package}/'));
        return (new Sass()
          ..scss = id.extension == '.scss'
          ..loadPath = options.includePaths
          ..executable = options.executable
        ).transform(content).then((output) {
          var newId = id.changeExtension('.css');
          transform.addOutput(new Asset.fromString(newId, output));
          // (this is to no output scss files in build folder)
          transform.consumePrimary(id);
        }).catchError((error) {
          print(error);
        });
      });
    }));
  }
}