import '../input.dart';
import '../type_info.dart';
import 'abi_generator.dart';

class AbiGeneratorDart extends AbiGenerator {
  late InputOptions _options;

  @override
  String generate(Input input) {
    _options = input.options;

    final contents = [
      input.options.preambleDart,

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
      _generateStructExtensionMapping(
        structName: structName,
        nativeName: nativeName,
        definition: definition,
      ),
      _generateStructExtensionToNative(
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

  String _generateStructExtensionMapping({
    required String structName,
    required String nativeName,
    required StructDefinition definition,
  }) {
    final allToDartParameters = definition.fields.entries.map((entry) {
      final fieldName = entry.key;
      final fieldTypeInfo = FieldTypeInfo.of(entry.value, options: _options);

      return '$fieldName: ${fieldTypeInfo.dartConvertFieldFromNative(fieldName)}';
    }).toList();

    final toDartParametersChain = allToDartParameters
        .map((line) => '$line,')
        .join('\n          ');

    final allFieldAssignments = definition.fields.entries.expand((entry) {
      final fieldName = entry.key;
      final fieldTypeInfo = FieldTypeInfo.of(entry.value, options: _options);

      return fieldTypeInfo.dartAssignFieldToNative(fieldName, 'ref.$fieldName');
    }).toList();

    final assignmentsChain = allFieldAssignments.length == 1
        ? '..${allFieldAssignments.single}'
        : allFieldAssignments
              .map((assignment) => '\n            ..$assignment')
              .join();

    return trimIndent('''
      extension ${structName}_Mapping on $nativeName {
        $structName toDart() => (
          $toDartParametersChain
        );

        void assignFromDart(Arena arena, $structName ref) => this$assignmentsChain;
      }
    ''');
  }

  String _generateStructExtensionToNative({
    required String structName,
    required String nativeName,
    required StructDefinition definition,
  }) {
    return trimIndent('''
      extension ${structName}_toNative on $structName {
        Pointer<$nativeName> toNative(Arena arena) =>
            arena<$nativeName>()..ref.assignFromDart(arena, this);
      }
    ''');
  }

  String _generateStructExtensionFree({
    required String structName,
    required String nativeName,
    required String nativeFreeFunctionName,
  }) {
    return trimIndent('''
      extension ${structName}_free on Pointer<$nativeName> {
        void free() => $nativeFreeFunctionName(this);
      }
    ''');
  }
}
