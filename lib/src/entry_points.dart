part of sass.transformer;

/// Manager to know which files to process
///
/// Suports inclusion/exclusion paths with wildcards (*).
/// Default values are '*.sass' and '*.html'
class EntryPoints {
  /// List of paths to be included in regular expression format
  List<RegExp> include = [];
  /// List of paths to be excluded in regular expression format
  List<RegExp> exclude = [];
  /// flag to check if there is only one entry point
  bool isSingle = false;

  /// add [paths] as base comparison
  ///
  /// [paths] could have * and !exclusion.
  ///
  /// Example:
  ///   '/dir1/*/dir3/dir4/*.sass'
  ///   '!dir2/dir3/dir4/*.sass'  exclusion path
  void addPaths(List<String> paths) {
    String path;
    if (paths == null) return;

    for (int i = 0; i < paths.length; i++) {
      path = paths[i];
      if (path.startsWith('!')) {
        path = path.substring(1);
        exclude.add(toRegExp(path));
      } else {
        include.add(toRegExp(path));
      }
    }
  }

  /// Creates a RegExp from a path with wildcards and normalize
  RegExp toRegExp(String path) {
    path = path.replaceAll(r'\', r'/'); //normalize
    path = path.replaceAll(r'/', r'\/');
    path = path.replaceAll('*', r'(.)*');
    return new RegExp(path, caseSensitive: false);
  }

  /// Load default values for check if nothing indicated
  void assureDefault(List<String> defaultValues) {
    if (include.isEmpty) {
      addPaths(defaultValues);
    }
    _getSingle();
  }

  /// Simple rule to know if only one file is processed.
  _getSingle() {
    int count = 0;
    String path;

    isSingle = true;
    for (int i = 0; i < include.length; i++) {
      path = include[i].pattern;
      if (path.endsWith('.sass') || path.endsWith('.scss')) {
        count++;
        if (path.contains('*') || count > 1) {
          isSingle = false;
          break;
        }
      }
    }
  }

  /// true is [path] is a valid entryPoint
  bool check(String path) {
    bool result = false;
    bool found;
    RegExp re;
    String candidate = path;
    candidate = candidate.replaceAll(r'\', r'/'); //normalize

    for (int i = 0; i < include.length; i++) {
      re = include[i];
      result = re.hasMatch(candidate);
      if (result) break;
    }

    if (result) {
      for (int i = 0; i < exclude.length; i++) {
        re = exclude[i];
        found = re.hasMatch(candidate);
        if (found) {
          result = false;
          break;
        }
      }
    }

    return result;
  }
}