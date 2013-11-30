library sass.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:path/path.dart';
import 'sass.dart';

class SassTransformer extends Transformer {

  final Map configuration;

  SassTransformer.asPlugin(this.configuration);

  bool _isPrimaryPath(String path) {
    if (posix.basename(path).startsWith('_'))
      return false;

    String extension = posix.extension(path);
    return extension == '.sass' || extension == '.scss';
  }

  Future<bool> isPrimary(Asset input) =>
    new Future.value(_isPrimaryPath(input.id.path));

  Future apply(Transform transform) {
    AssetId id = transform.primaryInput.id;

    Sass sass = new Sass();

    if (id.extension == '.scss')
      sass.scss = true;

    sass.loadPath.add(posix.dirname(id.path));

    return transform.primaryInput.readAsString().then((content) {
      return sass.transform(content).then((output) {
        var newId = transform.primaryInput.id.changeExtension('.css');
        transform.addOutput(new Asset.fromString(newId, output));
      });
    });
  }
}
