import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final packageName = input.packageName;
      final assetPathInPackage = input.packageRoot.resolve(
        'engine/cmake-build-debug/mixer_engine.dll',
      );

      output.assets.code.add(
        CodeAsset(
          package: packageName,
          name: 'mixer_engine/mixer_engine.g.dart',
          linkMode: DynamicLoadingBundled(),
          file: assetPathInPackage,
        ),
      );
    }
  });
}
