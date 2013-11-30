library sass;

import 'dart:async';
import 'dart:io';
import 'package:utf/utf.dart';
import 'package:path/path.dart';

class Sass {

  bool scss = false;
  String style = null; // nested, compact, compressed, expanded
  List<String> loadPath = [];
  bool lineNumbers = false;
  bool compass = false;

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

    return Process.start('sass', flags).then((Process process) {
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
          throw new Exception("error while executing sass: $errors");
        }
      });
    });
  }
}
