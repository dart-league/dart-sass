library sass.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:sass/sass.dart';
import 'package:barback/barback.dart';

main(List<String> args) {

  group('Parsing imports', () {
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


  group('Basic SCSS tests', () {
    Sass sass = new Sass();
    sass.scss = true;
    sass.style = 'compressed';

    if (!args.contains('--no-sass')) {
      test('Sass', () {
        sass.executable = 'sass';
        expect(sass.transform('h1 { h2 { color: red } }'), completion(equals("h1 h2{color:red}\n")));
      });
    }

    if (!args.contains('--no-sassc')) {
      test('SassC', () {
        sass.executable = 'sassc';
        expect(sass.transform('h1 { h2 { color: red } }'), completion(equals("h1 h2 {color:red;}")));
      });
    }
  });
}
