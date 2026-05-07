import '../input.dart';
import '../type_info.dart';
import 'abi_generator.dart';

class AbiGeneratorCpp extends AbiGenerator {
  late InputOptions _options;

  @override
  String generate(Input input) {
    _options = input.options;
    final contents = [
      input.options.preambleCpp,

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
    return [
      _generateStructFreeFunctionInternal(
        structName: structName,
        definition: definition,
      ),
      _generateStructFreeFunction(structName: structName),
    ].join('\n\n');
  }

  String _generateStructFreeFunctionInternal({
    required String structName,
    required StructDefinition definition,
  }) {
    final functionSignature = generateSignatureStructFreeFunctionInternal(
      structName: structName,
      options: _options,
    );

    final calls = definition.fields.entries.expand((entry) {
      final fieldName = entry.key;
      final fieldTypeInfo = FieldTypeInfo.of(entry.value, options: _options);

      return fieldTypeInfo.cCallFreeFunction('ref.$fieldName');
    });

    final fieldChain = calls.map((call) => '$call;').join('\n        ');

    return trimIndent('''
      $functionSignature {
        $fieldChain
      }
    ''');
  }

  String _generateStructFreeFunction({required String structName}) {
    final functionSignature = generateSignatureStructFreeFunction(
      structName: structName,
      options: _options,
    );

    final internalFreeFunctionName = _options.renameStructFreeFunctionInternal(
      structName,
    );

    return trimIndent('''
      $functionSignature {
        if (ref == nullptr) return;
        $internalFreeFunctionName(*ref);
        delete ref;
      }
    ''');
  }

  static String generateSignatureStructFreeFunction({
    required String structName,
    required InputOptions options,
  }) {
    final nativeStructName = options.renameStructInC(structName);
    final functionName = options.renameStructFreeFunction(structName);

    return 'void $functionName($nativeStructName* ref)';
  }

  static String generateSignatureStructFreeFunctionInternal({
    required String structName,
    required InputOptions options,
  }) {
    final nativeStructName = options.renameStructInC(structName);
    final functionName = options.renameStructFreeFunctionInternal(structName);

    return 'void $functionName($nativeStructName& ref)';
  }
}
