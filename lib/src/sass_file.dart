library sass.sass_file;

final RegExp _importRegex = new RegExp(r"""@import\s+('(.+?)'|"(.+?)")\s*;""");

class SassFile {
  final String contents;

  Iterable<Import> get imports => _importRegex
      .allMatches(contents)
      .map((match) => new Import(match.start, match.end, match[1].substring(1, match[1].length - 1)));

  SassFile(this.contents);
}

class Import {
  final int start;
  final int end;
  final String path;

  Import(this.start, this.end, this.path);
}