import 'dart:io';

import 'generators/abi_generator.dart';
import 'generators/abi_generator_c_header.dart';
import 'generators/abi_generator_cpp.dart';
import 'generators/abi_generator_dart.dart';
import 'generators/ffigen.dart';
import 'input.dart';

enum GenerateMode { all, onlyGenerateDartFromHeader }

Future<void> generateAbiBridge({
  required Input input,
  GenerateMode mode = .all,
}) async {
  final files = input.files;

  if (mode == .all) {
    await AbiGeneratorCHeader().generateFile(input, files.generatedCHeader);
    await AbiGeneratorCpp().generateFile(input, files.generatedCpp);
    await AbiGeneratorDart().generateFile(input, files.generatedDartStructs);
  }

  await generateFfigenOutput(
    entryPointerHeaderFile: files.entrypointHeader,
    generatedDartFile: files.generatedDart,
  );
}

extension on AbiGenerator {
  Future<void> generateFile(Input input, Uri outputFile) async {
    final output = generate(input);
    await File.fromUri(outputFile).writeAsString(output);
  }
}
