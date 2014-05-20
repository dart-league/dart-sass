library sass.inlined_sass_transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:sass/src/sass_file.dart';
import 'package:sass/src/inlined_sass_file.dart';
import 'package:code_transformers/assets.dart';
import 'package:sass/sass.dart';
import 'package:sass/transformer.dart';
import 'package:path/path.dart' as pathos;

class InlinedSassTransformer extends Transformer {
  final BarbackSettings settings;
  final TransformerOptions options;
  final Sass _sass;

  InlinedSassTransformer(BarbackSettings settings, this._sass) :
      settings = settings,
      options = new TransformerOptions.parse(settings.configuration) {
    _sass.executable = options.executable;
    _sass.style = options.style;
    _sass.compass = options.compass;
    _sass.lineNumbers = options.lineNumbers;
  }

  InlinedSassTransformer.asPlugin(BarbackSettings settings) :
    this(settings, new Sass());

  Future isPrimary(assetOrId) {
    var assetId = (assetOrId is Asset ? assetOrId.id : assetOrId) as AssetId;
    var extension = pathos.extension(assetId.path);
    return new Future.value(!pathos.basename(assetId.path).startsWith("_") &&
        (extension == ".scss" || extension == ".sass"));
  }

  Future apply(Transform transform) {
    var stopwatch = new Stopwatch();

    return _inlineSassImports(transform.primaryInput.id, transform)
        .then((sassFile) => _compile(sassFile, transform))
        .then((compiledOutput) {
          var inlinedAssetId = transform.primaryInput.id.changeExtension(".css");
          var inlinedAsset = new Asset.fromString(inlinedAssetId, compiledOutput);
          transform
              ..addOutput(inlinedAsset)
              ..consumePrimary();

          stopwatch.stop();
          transform.logger.info("Compiled $inlinedAssetId in ${stopwatch.elapsed}");
        });
  }

  Future<String> _compile(SassFile sassFile, Transform transform) {
    if (transform.primaryInput.id.extension == '.scss') {
      _sass.scss = true;
    }
    return _sass.transform(sassFile.contents);
  }

  Future<InlinedSassFile> _inlineSassImports(AssetId sassAsset, Transform transform) {
    return transform.readInputAsString(sassAsset).then((contents) {
      var sassFile = new SassFile(contents);
      var importedAssets = sassFile.imports.map((import) {
        var pathParts = pathos.split(import.path);
        var importFileName = "_${pathParts.last}${sassAsset.extension}";
        var importPath = pathos.joinAll(pathParts.take(pathParts.length - 1).toList()..add(importFileName));
        return uriToAssetId(transform.primaryInput.id, importPath, transform.logger, null);
      });

      return Future
          .wait(importedAssets.map((asset) => _inlineSassImports(asset, transform)))
          .then((sassFiles) {
            var imports = new Map.fromIterables(sassFile.imports, sassFiles);
            return new InlinedSassFile(contents, imports);
          });
    });
  }
}