library sass.inlined_transformer_test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import 'package:barback/barback.dart';
import 'package:sass/sass.dart';
import 'package:sass/inlined_sass_transformer.dart';

void main() => group("InlinedSassTransformer", () {
  InlinedSassTransformer createTransformer({Map configuration, Sass sass}) {
    configuration = configuration != null ? configuration : {};
    sass = sass != null ? sass : new SassMock();
    var settings = new BarbackSettings(configuration, BarbackMode.DEBUG);
    return new InlinedSassTransformer(settings, sass);
  }

  Matcher assetPathContains(String string) =>
    predicate((AssetId assetId) => assetId.path.contains(string), "Asset path contains '$string'");

  group('detecting primary assets', () {
    Future<bool> isPrimary(String path) => createTransformer().isPrimary(new AssetId('my_package', path));

    test('supported extensions should be recognized', () {
      expect(isPrimary('foo.sass'), completion(isTrue));
      expect(isPrimary('foo.scss'), completion(isTrue));
      expect(isPrimary('foo/foo.scss'), completion(isTrue));
    });

    test('unsupported extensions should not be primary assets', () {
      expect(isPrimary('foo.bar'), completion(isFalse));
    });

    test('files with leading underscore should also be primary assets', () {
      expect(isPrimary('_foo.scss'), completion(isTrue));
      expect(isPrimary('foo/_foo.scss'), completion(isTrue));
    });
  });

  group("apply()", () {
    SassMock sass;
    InlinedSassTransformer transformer;
    Asset asset;
    TransformMock transform;

    Transform createTransform(String importFoo, String importBar) {
      transform
          ..when(callsTo("hasInput", new AssetId("my_package", "foo.scss"))).alwaysReturn(new Future.value(true))
          ..when(callsTo("hasInput", new AssetId("my_package", "bar.scss"))).alwaysReturn(new Future.value(true))
          ..when(callsTo("readInputAsString", new AssetId("my_package", "foo.scss")))
              .alwaysReturn(new Future.value(importFoo))
          ..when(callsTo("readInputAsString", new AssetId("my_package", "bar.scss")))
              .alwaysReturn(new Future.value(importBar));

      return transform;
    }

    setUp(() {
      sass = new SassMock()..when(callsTo("get loadPath")).alwaysReturn([]);
      asset = new Asset.fromString(new AssetId("my_package", "primary"), "@import 'foo';\n@import 'bar';");
      transformer = createTransformer(sass: sass);
      transform = new TransformMock()
          ..when(callsTo("get primaryInput")).alwaysReturn(asset)
          ..when(callsTo("hasInput", asset.id)).alwaysReturn(new Future.value(true))
          ..when(callsTo("readInputAsString", asset.id)).thenReturn(asset.readAsString());
    });

    group("inlining", () {
      test("handles multiple imports", () {
        var foo = "inlined foo";
        var bar = "inlined bar";
        var transform = createTransform(foo, bar);

        return transformer.processInput(transform).then((contents) {
          expect(contents, equals("$foo\n$bar"));
        });
      });

      test("handles nested imports", () {
        var foo = "@import 'bar';";
        var bar = "bar";
        var transform = createTransform(foo, bar);

        return transformer.processInput(transform).then((contents) {
          expect(contents, equals("$bar\n$bar"));
        });
      });
    });

    group("with compass", () {
      setUp(() {
        transformer = createTransformer(configuration: {"compass": true}, sass: sass);
        asset = new Asset.fromString(new AssetId("my_package", "primary"), "@import 'compass';");
        sass.when(callsTo("transform")).alwaysReturn(asset.readAsString());
      });

      test("does not read compass imports", () {
        var transform = createTransform("foo", "bar");
        return transformer.apply(transform).then((_) {
          transform.getLogs(callsTo("readInputAsString", assetPathContains("compass"))).verify(neverHappened);
        });
      });
    });
  });
});

class SassMock extends Mock implements Sass {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class TransformMock extends Mock implements Transform {
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
