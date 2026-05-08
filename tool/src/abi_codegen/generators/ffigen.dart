import 'package:ffigen/ffigen.dart';

Future<void> generateFfigenOutput({
  required Uri entryPointerHeaderFile,
  required Uri generatedDartFile,
}) async {
  final relevantHeaderRootDirectory = entryPointerHeaderFile.resolve('..');

  FfiGenerator(
    output: Output(dartFile: generatedDartFile),

    functions: .includeAll,
    structs: .includeAll,
    enums: .includeAll,
    typedefs: .includeAll,
    unnamedEnums: .includeAll,

    headers: Headers(
      entryPoints: [entryPointerHeaderFile],
      include: (header) =>
          header.toString().startsWith(relevantHeaderRootDirectory.toString()),
      compilerOptions: ["-DMIXER_ENGINE_ABI_BUILDING=1"],
    ),
  ).generate();
}
