@TestOn('vm')
library sass.transformer.test;

import 'package:test/test.dart';
import 'package:mock/mock.dart';
import 'package:sass/transformer.dart';
import 'package:barback/barback.dart';
import 'package:sass/sass.dart';

main() {
  SassTransformer createTransformer({Map configuration, Sass sass}) {
    configuration = configuration != null ? configuration : {};
    sass = sass != null ? sass : new SassMock();
    var settings = new BarbackSettings(configuration, BarbackMode.DEBUG);
    return new SassTransformer(settings, sass);
  }

  bool isPrimary(String path) =>
    createTransformer().isPrimary(new AssetId('my_package', path));

  Matcher assetPathContains(String string) =>
    predicate((AssetId assetId) => assetId.path.contains(string), "Asset path contains '$string'");

  group('detecting primary assets', () {
    test('supported extensions should be recognized', () {
      expect(isPrimary('foo.sass'), isTrue);
      expect(isPrimary('foo.scss'), isTrue);
      expect(isPrimary('foo/foo.scss'), isTrue);
    });

    test('unsupported extensions should not be primary assets', () {
      expect(isPrimary('foo.bar'), isFalse);
    });

    test('files with leading underscore should also be primary assets', () {
      expect(isPrimary('_foo.scss'), isTrue);
      expect(isPrimary('foo/_foo.scss'), isTrue);
    });
  });

  group("apply()", () {
    SassMock sass;
    SassTransformer transformer;

    setUp(() {
      sass = new SassMock()..when(callsTo("get loadPath")).alwaysReturn([]);
    });

    group("with compass", () {
      Asset asset;

      setUp(() {
        transformer = createTransformer(configuration: {"compass": true}, sass: sass);
        asset = new Asset.fromString(new AssetId("my_package", "primary"), "@import 'compass';");
        sass.when(callsTo("transform")).alwaysReturn(asset.readAsString());
      });

      test("does not read compass imports", () {
        var transform = new TransformMock()
            ..when(callsTo("get primaryInput")).alwaysReturn(asset)
            ..when(callsTo("readInputAsString", asset.id)).thenReturn(asset.readAsString());

        transformer.apply(transform).then(expectAsync((_) {
          var assetPathContainsCompass = predicate(
              (AssetId assetId) => assetId.path.contains("compass"),
              "Asset path contains 'compass'");
          transform.getLogs(callsTo("readInputAsString", assetPathContains("compass"))).verify(neverHappened);
        }));
      });
    });
  });
}

class SassMock extends Mock implements Sass {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class TransformMock extends Mock implements Transform {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
