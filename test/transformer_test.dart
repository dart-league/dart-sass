library sass.transformer.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
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

  Future<bool> isPrimary(String path) {
    var asset = new Asset.fromString(new AssetId('my_package', path), 'my-contents');
    return createTransformer().isPrimary(asset);
  }

  Matcher assetPathContains(String string) {
    return predicate((AssetId assetId) => assetId.path.contains(string), "Asset path contains '$string'");
  }

  group('detecting primary assets', () {
    test('supported extensions should be recognized', () {
      expect(isPrimary('foo.sass'), completion(isTrue));
      expect(isPrimary('foo.scss'), completion(isTrue));
      expect(isPrimary('foo/foo.scss'), completion(isTrue));
    });

    test('unsupported extensions should not be primary assets', () {
      expect(isPrimary('foo.bar'), completion(isFalse));
    });

    test('files with leading underscore should not be primary assets', () {
      expect(isPrimary('_foo.scss'), completion(isFalse));
      expect(isPrimary('foo/_foo.scss'), completion(isFalse));
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
