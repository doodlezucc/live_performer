import 'dart:io';

import 'package:ffigen/ffigen.dart';

import 'generators/abi_generator_c_header.dart';
import 'generators/abi_generator_cpp.dart';
import 'generators/abi_generator_dart.dart';
import 'input.dart';

Future<void> generateAbiBridge(Input input) async {
  final cHeaderOutput = AbiGeneratorCHeader().generate(input);

  await File.fromUri(
    input.files.generatedCHeaderFile,
  ).writeAsString(cHeaderOutput);

  final customDartOutput = AbiGeneratorDart().generate(input);

  final relevantHeaderRootDirectory = input.files.entrypointHeaderFile.resolve(
    '..',
  );

  FfiGenerator(
    output: Output(dartFile: input.files.generatedDartFile),

    functions: .includeAll,
    structs: .includeAll,
    enums: .includeAll,
    typedefs: .includeAll,
    unnamedEnums: .includeAll,

    headers: Headers(
      entryPoints: [input.files.entrypointHeaderFile],
      include: (header) {
        return header.toString().startsWith(
          relevantHeaderRootDirectory.toString(),
        );
      },
      compilerOptions: ["-DMIXER_ENGINE_ABI_BUILDING=1"],
    ),
  ).generate();

  final ffigenOutputFile = File.fromUri(input.files.generatedDartFile);

  final ffigenContents = await ffigenOutputFile.readAsString();

  await ffigenOutputFile.writeAsString('''
${input.options.preambleDart}

$ffigenContents

$customDartOutput''');

  final cppOutput = AbiGeneratorCpp().generate(input);

  await File.fromUri(
    input.files.generatedCppFile,
  ).writeAsString('\n$cppOutput');
}
