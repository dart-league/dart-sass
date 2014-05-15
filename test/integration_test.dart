library sass.transformer.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import 'package:sass/transformer.dart';
import 'package:barback/barback.dart';
import 'package:sass/sass.dart';

const testPackage = 'test';

main(List<String> args) {
  if (args.contains('--no-sass'))
    return;

  group('integration tests', () {
    var packageProvider = new MockPackageProvider();
    var config = { 'style': 'compact' };
    var barback = new Barback(packageProvider);
    var transformer = new SassTransformer.asPlugin(new BarbackSettings(config, BarbackMode.DEBUG));

    test('transform with barback', () {
      barback.updateSources([new AssetId(testPackage, 'foo/foo.scss')]);
      barback.updateTransformers(testPackage, [[transformer]]);

      var outputId = new AssetId(testPackage, 'foo/foo.css');
      expect(barback.getAssetById(outputId).then((x) => x.readAsString()), completion(".foo h1 { color: red; }\n"));
    });
  });
}

class MockPackageProvider extends PackageProvider {

  Iterable<String> get packages =>
    [testPackage];

  Future<Asset> getAsset(AssetId id) =>
    new Future(() => new Asset.fromString(id, r".foo { $col: red; h1 { color: $col; } }"));
}
