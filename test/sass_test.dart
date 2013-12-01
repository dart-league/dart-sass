library sass.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:sass/sass.dart';
import 'package:barback/barback.dart';

main() {

  group('parsing imports', () {
    test('import supports single quotes', () {
      expect(Sass.resolveImportsFromSource("@import 'foo';"), equals(['foo']));
    });

    test('import supports double quotes', () {
      expect(Sass.resolveImportsFromSource('@import "foo";'), equals(['foo']));
    });

    test('multiple imports', () {
      expect(Sass.resolveImportsFromSource("@import 'foo'; @import 'bar';"), equals(['foo', 'bar']));
    });
  });

}
