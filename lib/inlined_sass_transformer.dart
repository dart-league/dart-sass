library sass.inlined_sass_transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:sass/src/sass_file.dart';
import 'package:sass/src/inlined_sass_file.dart';
import 'package:sass/sass.dart';
import 'package:sass/src/base_sass_transformer.dart';

class InlinedSassTransformer extends BaseSassTransformer {
  InlinedSassTransformer(BarbackSettings settings, Sass sass) :
    super(settings, sass);

  InlinedSassTransformer.asPlugin(BarbackSettings settings) :
    this(settings, new Sass());

  @override
  Future<String> processInput(Transform transform) {
    return _inlineSassImports(transform.primaryInput.id, transform)
        .then((sassFile) => sassFile.contents);
  }

  Future<InlinedSassFile> _inlineSassImports(AssetId sassAsset, Transform transform) {
    return transform.readInputAsString(sassAsset).then((contents) {
      var sassFile = new SassFile(contents);
      var filteredImports = filterImports(sassFile.imports);
      var importedAssets = filteredImports.map((import) =>
        resolveImportAssetId(transform, sassAsset, import.path)
      );

      return Future.wait(importedAssets.map((asset) => _inlineSassImports(asset, transform)))
          .then((sassFiles) {
            var imports = new Map.fromIterables(filteredImports, sassFiles);
            return new InlinedSassFile(contents, imports);
          });
    });
  }
}
