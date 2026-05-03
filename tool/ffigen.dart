import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  final headerFile = packageRoot.resolve(
    'engine/include/mixer_engine/mixer_engine_abi.h',
  );

  FfiGenerator(
    output: Output(dartFile: packageRoot.resolve('lib/mixer_engine.g.dart')),

    functions: .includeAll,
    structs: .includeAll,
    enums: .includeAll,
    typedefs: .includeAll,
    unnamedEnums: .includeAll,

    headers: Headers(
      entryPoints: [headerFile],
      include: (header) => header == headerFile,
      compilerOptions: ["-DMIXER_ENGINE_ABI_BUILDING=1"],
    ),
  ).generate();
}
