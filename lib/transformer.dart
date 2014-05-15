library sass.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:path/path.dart';
import 'sass.dart';

/// Transformer used by `pub build` and `pub serve` to convert Sass-files to CSS.
class SassTransformer extends Transformer implements DeclaringTransformer {
  final BarbackSettings settings;
  final TransformerOptions options;
  final Sass _sass;

  SassTransformer(BarbackSettings settings, this._sass) :
    settings = settings,
    options = new TransformerOptions.parse(settings.configuration);

  SassTransformer.asPlugin(BarbackSettings settings) :
    this(settings, new Sass());

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

      if (options.compass) {
        imports = _excludeCompassImports(imports);
      }

      return Future.wait(imports.map((module) {
        var name = module.contains('.') ? module : "_$module${assetId.extension}";
        var path = posix.join(posix.dirname(assetId.path), name);
        return _readImportsRecursively(transform, new AssetId(assetId.package, path));
      }));
    });

  Iterable<String> _excludeCompassImports(Iterable<String> imports) {
    return imports.where((import) => !import.startsWith("compass"));
  }

  Future apply(Transform transform) {
    AssetId primaryAssetId = transform.primaryInput.id;

    return _readImportsRecursively(transform, primaryAssetId).then((_) {
      _sass.executable = options.executable;
      _sass.style = options.style;
      _sass.compass = options.compass;
      _sass.lineNumbers = options.lineNumbers;

      if (primaryAssetId.extension == '.scss') {
        _sass.scss = true;
      }

      _sass.loadPath.add(posix.dirname(primaryAssetId.path));

      return transform.primaryInput.readAsString().then((content) =>
        _sass.transform(content).then((output) {
          var newId = primaryAssetId.changeExtension('.css');
          transform.addOutput(new Asset.fromString(newId, output));
        }));
    }).catchError((SassException e) {
      transform.logger.error("error: ${e.message}");
    }, test: (e) => e is SassException);
  }

  Future declareOutputs(DeclaringTransform transform) {
    AssetId primaryAssetId = transform.primaryInput.id;
    transform.declareOutput(primaryAssetId.changeExtension('.css'));

    return new Future.value();
  }
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
