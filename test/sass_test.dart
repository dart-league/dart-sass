@TestOn('vm')
library sass.test;

import 'package:test/test.dart';
import 'package:sass/sass.dart';

main() {
  Matcher regexMatch(RegExp regexp) =>
      predicate((String s) => regexp.hasMatch(s));

  group('Basic SCSS tests', () {
    Sass sass = new Sass();
    sass.scss = true;
    sass.style = 'compressed';

    test('Sass', () {
      final expected = regexMatch(new RegExp("^h1 h2\s*{color:red}\n\$"));
      expect(sass.transform('h1 { h2 { color: red } }'), completion(expected));

      expect(sass.transform('h1 { h2{ color: red } }'), completion(expected));
    });
  });
}
