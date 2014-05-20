library sass.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:path/path.dart';
import 'package:sass/src/base_sass_transformer.dart';
import 'package:sass/sass.dart';

/// Transformer used by `pub build` and `pub serve` to convert Sass-files to CSS.
class SassTransformer extends BaseSassTransformer {
  SassTransformer(BarbackSettings settings, Sass sass) :
    super(settings, sass);

  SassTransformer.asPlugin(BarbackSettings settings) :
    this(settings, new Sass());

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

  @override
  Future<String> processInput(Transform transform) {
    return _readImportsRecursively(transform, transform.primaryInput.id);
  }
}
