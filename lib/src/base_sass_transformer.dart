library sass.base_sass_transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:sass/sass.dart';
import 'package:path/path.dart';
import 'package:sass/src/sass_file.dart';

abstract class BaseSassTransformer extends Transformer implements DeclaringTransformer {
  final BarbackSettings settings;
  final TransformerOptions options;
  final Sass _sass;

  BaseSassTransformer(BarbackSettings settings, this._sass) :
    settings = settings,
    options = new TransformerOptions.parse(settings.configuration);

  bool isPrimary(AssetId input) {
    // We consider all .scss and .sass files primary although in reality we process only
    // the ones that don't start with an underscore. This way we can call consumePrimary()
    // for all files and they don't end up in the build-directory.
    var extension = posix.extension(input.path);
    var primary = extension == '.sass' || extension == '.scss';

    return primary;
  }

  declareOutputs(DeclaringTransform transform) {
    AssetId primaryAssetId = transform.primaryId;
    if (_isPartial(primaryAssetId))
      return;

    transform.declareOutput(primaryAssetId.changeExtension('.css'));
  }

  Future apply(Transform transform) {
    AssetId primaryAssetId = transform.primaryInput.id;

    if (!options.copySources)
      transform.consumePrimary();

    if (_isPartial(primaryAssetId))
      return new Future.value();

    return processInput(transform).then((content) {
      _sass.executable = options.executable;
      _sass.style = options.style;
      _sass.compass = options.compass;
      _sass.lineNumbers = options.lineNumbers;

      if (primaryAssetId.extension == '.scss') {
        _sass.scss = true;
      }

      _sass.loadPath.add(posix.dirname(primaryAssetId.path));

      return _sass.transform(content).then((output) {
        var newId = transform.primaryInput.id.changeExtension('.css');
        transform.addOutput(new Asset.fromString(newId, output));
      });
    });
  }

  bool _isPartial(AssetId asset) => posix.basename(asset.path).startsWith('_');

  Future<String> processInput(Transform transform);

  Iterable<Import> filterImports(Iterable<Import> imports) {
    if (options.compass) {
      return imports.where((import) => !import.path.startsWith("compass"));
    } else {
      return imports;
    }
  }

  Future<AssetId> resolveImportAssetId(Transform transform, AssetId assetId, Import import) {
    var assetIds = _candidateAssetIds(assetId, import);

    return _firstExisting(transform, assetIds).then((id) {
      if (id != null)
        return id;
      else
        return new Future.error(new SassException("could not resolve import '$import' (tried $assetIds)"));
    });
  }

  /// Returns the first existing assetId from assetIds, or null if none is found.
  Future<AssetId> _firstExisting(Transform transform, List<AssetId> assetIds) {
    loop(int index) {
      if (index >= assetIds.length)
        return new Future.value(null);

      var assetId = assetIds[index];
      return transform.hasInput(assetId).then((exists) {
        if (exists)
          return new Future.value(assetId);
        else
          return loop(index+1);
      });
    }

    return loop(0);
  }

  List<AssetId> _candidateAssetIds(AssetId assetId, Import import) {
    var names = [];

    var dirname = posix.dirname(import.path);
    var basename = posix.basename(import.path);

    if (basename.contains('.')) {
      names.add(basename);
      names.add("_$basename");
    } else {
      names.add("$basename.scss");
      names.add("$basename.sass");
      names.add("_$basename.scss");
      names.add("_$basename.sass");
    }

    return names.map((n) => new AssetId(assetId.package, posix.join(posix.dirname(assetId.path), dirname, n))).toList();
  }
}

class TransformerOptions {
  final String executable;
  final String style;
  final bool compass;
  final bool lineNumbers;
  final bool copySources;

  TransformerOptions({String this.executable, String this.style, bool this.compass, bool this.lineNumbers, bool this.copySources});

  factory TransformerOptions.parse(Map configuration) {
    config(key, defaultValue) {
      var value = configuration[key];
      return value != null ? value : defaultValue;
    }

    return new TransformerOptions(
        executable: config("executable", Sass.defaultExecutable),
        style: config("style", null),
        compass: config("compass", false),
        lineNumbers: config("line-numbers", false),
        copySources: config("copy-sources", false));
  }
}
