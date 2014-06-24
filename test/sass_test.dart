library sass.test;

import 'package:unittest/unittest.dart';
import 'package:sass/sass.dart';

main(List<String> args) {
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
