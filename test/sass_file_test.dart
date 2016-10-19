@TestOn('vm')
library dart_sass_transformer.sass_file_test;

import 'package:test/test.dart';
import 'package:dart_sass_transformer/transformer.dart';

void main() => group("SassFile", () {
  group("imports", () {
    test("includes imports with single quotes", () {
      var sassFile = new SassFile("@import 'foo';");
      expect(sassFile.imports.map((import) => import.path), equals(["foo"]));
    });

    test("includes imports with double quotes", () {
      var sassFile = new SassFile('@import "foo";');
      expect(sassFile.imports.map((import) => import.path), equals(["foo"]));
    });

    test("includes all imports", () {
      var sassFile = new SassFile('@import "foo"; @import "bar";');
      expect(sassFile.imports.map((import) => import.path), equals(["foo", "bar"]));
    });

    test("ignores url imports", () {
      var sassFile = new SassFile('@import url("foo");');
      expect(sassFile.imports.isEmpty, isTrue);
    });

    test("imports containing word url are ok", () {
      var sassFile = new SassFile("@import 'url_foo';");
      expect(sassFile.imports.map((import) => import.path), equals(['url_foo']));
    });

    test("imports have correct start and end values", () {
      var sassFile = new SassFile('@import "foo"; @import "bar";');
      var fooImport = sassFile.imports.first;
      var barImport = sassFile.imports.last;

      expect(fooImport.start, equals(0));
      expect(fooImport.end, equals(14));

      expect(barImport.start, equals(15));
      expect(barImport.end, equals(29));
    });
  });
});
