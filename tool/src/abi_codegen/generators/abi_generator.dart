import '../input.dart';

abstract class AbiGenerator {
  String generate(Input input);
}

final _nonSpaceCharacter = RegExp(r'\S');

String trimIndent(String source) {
  final lines = source.split('\n');

  int shortestIndent = source.length;

  for (final line in lines) {
    final firstNonSpaceIndex = line.indexOf(_nonSpaceCharacter);

    if (firstNonSpaceIndex >= 0) {
      if (firstNonSpaceIndex < shortestIndent) {
        shortestIndent = firstNonSpaceIndex;
      }
    }
  }

  if (lines.length > 1 && !lines.last.contains(_nonSpaceCharacter)) {
    // Last line is all whitespace
    lines.removeLast();
  }

  return lines
      .map(
        (line) =>
            line.length >= shortestIndent ? line.substring(shortestIndent) : '',
      )
      .join('\n');
}
