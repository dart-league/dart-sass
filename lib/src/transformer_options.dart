part of sass.transformer;

/// Class to be used to parse sass transformer options coming from pubspec.yaml file
class TransformerOptions {

  /// include_path: /lib/sassIncludes - variable and mixims files
  final List<String> includePaths;

  /// output: web/output.css - result file. If '' same as web/input.css
  final String output;

  /// executable: sassc - command to execute sassc  - NOT USED
  final String executable;
  final String style;
  final bool compass;
  final bool lineNumbers;
  final bool copySources;

  TransformerOptions({
    this.includePaths,
    this.output,
    this.executable,
    this.style,
    this.compass,
    this.lineNumbers,
    this.copySources
  });

  factory TransformerOptions.parse(Map configuration){
    config(key, defaultValue) {
      var value = configuration[key];
      return value ?? defaultValue;
    }

    List<String> readStringList(value, [defaultValue]) {
      if (value is List<String>) return value;
      if (value is String) return [value];
      return value ?? defaultValue;
    }

    return new TransformerOptions (
        includePaths: readStringList(configuration['include_paths'], []),
        output: config('output', ''),
        executable: config('executable', (Platform.operatingSystem == "windows" ? "sass.bat" : "sass")),
        style: config("style", null),
        compass: config("compass", false),
        lineNumbers: config("line_numbers", false),
        copySources: config("copy_sources", false)
    );
  }
}