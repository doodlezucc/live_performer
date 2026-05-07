import '../input.dart';
import '../type_info.dart';
import 'abi_generator.dart';

class AbiGeneratorDart {
  late InputOptions _options;

  String generate(Input input) {
    _options = input.options;

    final contents = [
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
    final nativeFreeFunctionName = _options.renameStructFreeFunction(
      structName,
    );

    return [
      _generateStructTypedef(name: structName, definition: definition),
      _generateStructExtensionToNative(
        structName: structName,
        nativeName: nativeName,
        definition: definition,
      ),
      _generateStructExtensionToDart(
        structName: structName,
        nativeName: nativeName,
        definition: definition,
      ),
      _generateStructExtensionFree(
        structName: structName,
        nativeName: nativeName,
        nativeFreeFunctionName: nativeFreeFunctionName,
      ),
    ].join('\n\n');
  }

  String _generateStructTypedef({
    required String name,
    required StructDefinition definition,
  }) {
    final allFields = definition.fields.entries.map((entry) {
      final fieldName = entry.key;
      final fieldTypeInfo = FieldTypeInfo.of(entry.value, options: _options);

      return '${fieldTypeInfo.dartName} $fieldName';
    }).toList();

    final fieldsChain = allFields.map((line) => '$line,').join('\n        ');

    return trimIndent('''
      typedef $name = ({
        $fieldsChain
      });
    ''');
  }

  String _generateStructExtensionToNative({
    required String structName,
    required String nativeName,
    required StructDefinition definition,
  }) {
    final allFieldAssignments = definition.fields.entries.expand((entry) {
      final fieldName = entry.key;
      final fieldTypeInfo = FieldTypeInfo.of(entry.value, options: _options);

      return fieldTypeInfo.dartAssignFieldToNative(fieldName);
    }).toList();

    final assignmentsChain = allFieldAssignments.length == 1
        ? '.${allFieldAssignments.single}'
        : allFieldAssignments
              .map((assignment) => '\n            ..$assignment')
              .join();

    return trimIndent('''
      extension ${structName}_toNative on $structName {
        ffi.Pointer<$nativeName> toNative(Arena arena) {
          final result = arena<$nativeName>();
          result.ref$assignmentsChain;
          return result;
        }
      }
    ''');
  }

  String _generateStructExtensionToDart({
    required String structName,
    required String nativeName,
    required StructDefinition definition,
  }) {
    final allParameters = definition.fields.entries.map((entry) {
      final fieldName = entry.key;
      final fieldTypeInfo = FieldTypeInfo.of(entry.value, options: _options);

      return '$fieldName: ${fieldTypeInfo.dartConvertFieldFromNative(fieldName)}';
    }).toList();

    final parametersChain = allParameters
        .map((line) => '$line,')
        .join('\n          ');

    return trimIndent('''
      extension ${structName}_toDart on $nativeName {
        $structName toDart() => (
          $parametersChain
        );
      }
    ''');
  }

  String _generateStructExtensionFree({
    required String structName,
    required String nativeName,
    required String nativeFreeFunctionName,
  }) {
    return trimIndent('''
      extension ${structName}_free on ffi.Pointer<$nativeName> {
        void free() => $nativeFreeFunctionName(this);
      }
    ''');
  }
}
