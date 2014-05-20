library sass.base_sass_transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:sass/sass.dart';
import 'package:path/path.dart';

abstract class BaseSassTransformer extends Transformer implements DeclaringTransformer {
  final BarbackSettings settings;
  final TransformerOptions options;
  final Sass _sass;

  BaseSassTransformer(BarbackSettings settings, this._sass) :
    settings = settings,
    options = new TransformerOptions.parse(settings.configuration);

  bool _isPrimaryPath(String path) {
    if (posix.basename(path).startsWith('_'))
      return false;

    String extension = posix.extension(path);
    return extension == '.sass' || extension == '.scss';
  }

  Future<bool> isPrimary(input) =>
    // Hack to make the transformer compatible with Barback 0.13.x
    new Future.value(_isPrimaryPath(input is Asset ? input.id.path : input.path));

  Future declareOutputs(DeclaringTransform transform) {
    AssetId primaryAssetId = transform.primaryInput.id;
    transform.declareOutput(primaryAssetId.changeExtension('.css'));

    return new Future.value();
  }

  Future apply(Transform transform) {
    // Don't include the SASS file in the build.
    transform.consumePrimary();

    return processInput(transform).then((content) {
      _sass.executable = options.executable;
      _sass.style = options.style;
      _sass.compass = options.compass;
      _sass.lineNumbers = options.lineNumbers;

      if (transform.primaryInput.id.extension == '.scss') {
        _sass.scss = true;
      }

      return _sass.transform(content).then((output) {
        var newId = transform.primaryInput.id.changeExtension('.css');
        transform.addOutput(new Asset.fromString(newId, output));
      });
    });
  }

  Future<String> processInput(Transform transform);
}

class TransformerOptions {
  final String executable;
  final String style;
  final bool compass;
  final bool lineNumbers;

  TransformerOptions({String executable, String style, bool compass, bool lineNumbers}) :
    executable = executable != null ? executable : "sass",
    style = style,
    compass = compass != null ? compass : false,
    lineNumbers = lineNumbers != null ? lineNumbers : false;

  factory TransformerOptions.parse(Map configuration) {
    return new TransformerOptions(
        executable: configuration["executable"],
        style: configuration["style"],
        compass: configuration["compass"],
        lineNumbers: configuration["line-numbers"]);
  }
}
