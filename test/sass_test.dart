@TestOn('vm')
library dart_sass_transformer.test;

import 'package:test/test.dart';
import 'package:dart_sass_transformer/sass.dart';

main(List<String> args) {
  Matcher regexMatch(RegExp regexp) =>
      predicate((String s) => regexp.hasMatch(s));

  group('Basic SCSS tests', () {
    Sass sass = new Sass();
    sass.scss = true;
    sass.style = 'compressed';

    if (!args.contains('--no-sass')) {
      test('Sass', () {
        final expected = regexMatch(new RegExp("^h1 h2\s*{color:red}\n\$"));
        sass.executable = 'sass';
        expect(
            sass.transform('h1 { h2 { color: red } }'), completion(expected));

        expect(sass.transform('h1 { h2{ color: red } }'), completion(expected));
      });
    }

    if (!args.contains('--no-sassc')) {
      test('SassC', () {
        final expected = regexMatch(new RegExp("^h1 h2\s*{color:red}\n\$"));
        sass.executable = 'sassc';
        expect(
            sass.transform('h1 { h2 { color: red } }'), completion(expected));
        expect(sass.transform('h1 { h2{ color: red } }'), completion(expected));
      });
    }
  });
}
