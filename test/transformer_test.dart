@TestOn('vm')
library sass.transformer.test;

import 'dart:async';
import 'dart:io';
import 'package:test/test.dart';
import 'package:sass/transformer.dart';
import 'package:barback/barback.dart';

const testPackage = 'test';

main() {
  group('transformer tests', () {
    var packageProvider = new MockPackageProvider();
    var config = {
      'style': 'compact'
    };
    var barback = new Barback(packageProvider);
    var transformer = new SassTransformer.asPlugin(new BarbackSettings(config, BarbackMode.DEBUG));

    test('transform with barback', () {
      barback.updateSources([new AssetId(testPackage, 'test/foo/foo.scss')]);
      barback.updateTransformers(testPackage, [[transformer]]);

      var outputId = new AssetId(testPackage, 'test/foo/foo.css');
      expect(barback.getAssetById(outputId).then((x) => x.readAsString()),
          completion('.foo h1 {\n'
              '  color: red; }\n'
              ''));
    });
  });
}

class MockPackageProvider extends PackageProvider {

  Iterable<String> get packages => [testPackage];

  Future<Asset> getAsset(AssetId id) =>
      new Future(() => new Asset.fromFile(id, new File('test/foo/foo.scss')));
}
