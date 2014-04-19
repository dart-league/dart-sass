library sass.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:path/path.dart';
import 'sass.dart';

/// Transformer used by `pub build` and `pub serve` to convert Sass-files to CSS.
class SassTransformer extends Transformer {

  final BarbackSettings settings;

  SassTransformer.asPlugin(this.settings);

  bool _isPrimaryPath(String path) {
    if (posix.basename(path).startsWith('_'))
      return false;

    String extension = posix.extension(path);
    return extension == '.sass' || extension == '.scss';
  }

  Future<bool> isPrimary(Asset input) =>
    new Future.value(_isPrimaryPath(input.id.path));

  /// Reads all the imports of module so that Barback realizes that we depend on them.
  ///
  /// When Barback calls the transformer to process foo.scss, it will keep track of all
  /// read-calls so it knows which files foo.scss is dependent on. So if foo.scss
  /// imports bar.scss (and therefore we perform dummy read on bar.scss as well),
  /// Barback knows that if bar.scss changes, it will need to recompile foo.scss.
  /// This doesn't matter when executing a batch build with "pub build", but it's
  /// really important with "pub serve".
  Future _readImportsRecursively(Transform transform, AssetId assetId) =>
    transform.readInputAsString(assetId).then((source) {
      var imports = Sass.resolveImportsFromSource(source);
      return Future.wait(imports.map((module) {
        var name = module.contains('.') ? module : "_$module${assetId.extension}";

        var path = posix.join(posix.dirname(assetId.path), name);
        return _readImportsRecursively(transform, new AssetId(assetId.package, path));
      }));
    });

  Future apply(Transform transform) {
    AssetId primaryAssetId = transform.primaryInput.id;

    return _readImportsRecursively(transform, primaryAssetId).then((_) {
      Sass sass = new Sass();

      String executable = settings.configuration['executable'];
      if (executable != null)
        sass.executable = executable;

      sass.style = settings.configuration['style'];
      sass.compass = settings.configuration['compass'];
      sass.lineNumbers = settings.configuration['line-numbers'];

      if (primaryAssetId.extension == '.scss')
        sass.scss = true;

      sass.loadPath.add(posix.dirname(primaryAssetId.path));

      return transform.primaryInput.readAsString().then((content) =>
        sass.transform(content).then((output) {
          var newId = primaryAssetId.changeExtension('.css');
          transform.addOutput(new Asset.fromString(newId, output));
        }));
    }).catchError((SassException e) {
      transform.logger.error("error: ${e.message}");
    }, test: (e) => e is SassException);
  }
}
