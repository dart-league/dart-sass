library sass;

import 'dart:async';
import 'dart:io';
import 'package:utf/utf.dart';
import 'package:path/path.dart';

/// Facade for Sass-transformations.
class Sass {

  String executable = "sass";
  bool scss = false;
  String style = null; // nested, compact, compressed, expanded
  List<String> loadPath = [];
  bool lineNumbers = false;
  bool compass = false;
  static final RegExp _importRegex = new RegExp(r"@import\s+(.+?);");

  /// Transforms given Sass-source to CSS.
  Future<String> transform(String content) {
    var flags = [];

    if (scss)
      flags.add('--scss');

    if (lineNumbers)
      flags.add('--line-numbers');

    if (compass)
      flags.add('--compass');

    if (style != null)
      flags..add('--style')..add(style);

    loadPath.forEach((dir) {
      flags..add('--load-path')..add(dir);
    });

    return Process.start(executable, flags).then((Process process) {
      StringBuffer errors = new StringBuffer();
      StringBuffer output = new StringBuffer();

      process.stdin.write(content);
      process.stdin.close();
      process.stdout.transform(new Utf8DecoderTransformer()).listen((str) => output.write(str));
      process.stderr.transform(new Utf8DecoderTransformer()).listen((str) => errors.write(str));

      return process.exitCode.then((exitCode) {
        if (exitCode == 0) {
          return output.toString();
        } else {
          throw new SassException(errors.toString());
        }
      });
    }).catchError((ProcessException e) {
      throw new SassException(e.toString());
    }, test: (e) => e is ProcessException);
  }

  /// Returns the imports defined in given source.
  static List<String> resolveImportsFromSource(String source) =>
    _importRegex.allMatches(source).map((Match m) {
      var str = m.group(1);
      return str.substring(1, str.length-1);
    });
}

/// Exception thrown when there's a problem transforming Sass.
class SassException implements Exception {

  final String message;

  SassException(this.message);

  String toString() => message;
}
