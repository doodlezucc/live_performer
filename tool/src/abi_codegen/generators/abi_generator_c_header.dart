import '../input.dart';
import '../type_info.dart';
import 'abi_generator.dart';
import 'abi_generator_cpp.dart';

class AbiGeneratorCHeader extends AbiGenerator {
  late InputOptions _options;

  @override
  String generate(Input input) {
    _options = input.options;
    final contents = [
      input.options.preambleCHeader,

      ...input.structs.entries.map(
        (entry) =>
            _generateStruct(structName: entry.key, definition: entry.value),
      ),
    ].join('\n\n');

    return '$contents\n';
  }

  String _generateStruct({
    required String structName,
    required StructDefinition definition,
  }) {
    final nativeName = _options.renameStructInC(structName);

    return [
      _generateStructTypedef(
        nativeStructName: nativeName,
        definition: definition,
      ),
      _generateStructFreeFunction(structName: structName),
    ].join('\n\n');
  }

  String _generateStructTypedef({
    required String nativeStructName,
    required StructDefinition definition,
  }) {
    final fields = definition.fields.entries.expand((entry) {
      final fieldName = entry.key;
      final fieldTypeInfo = FieldTypeInfo.of(entry.value, options: _options);

      return fieldTypeInfo.cDeclareInStruct(fieldName);
    });

    final fieldChain = fields
        .map((declaration) => '$declaration;')
        .join('\n        ');

    return trimIndent('''
      typedef struct {
        $fieldChain
      } $nativeStructName;
    ''');
  }

  String _generateStructFreeFunction({required String structName}) {
    final exportMacro = _options.abiExportMacroName;
    final functionSignature =
        AbiGeneratorCpp.generateSignatureStructFreeFunction(
          structName: structName,
          options: _options,
        );

    return '$exportMacro $functionSignature;';
  }
}
