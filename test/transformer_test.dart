library sass.transformer.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:sass/transformer.dart';
import 'package:barback/barback.dart';

main() {

  SassTransformer createTransformer([Map configuration]) {
    configuration = configuration != null ? configuration : {};
    var settings = new BarbackSettings(configuration, BarbackMode.DEBUG);
    return new SassTransformer.asPlugin(settings);
  }

  Future<bool> isPrimary(String path) {
    var asset = new Asset.fromString(new AssetId('my_package', path), 'my-contents');
    return createTransformer().isPrimary(asset);
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

}
