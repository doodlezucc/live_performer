import 'input.dart';

sealed class FieldTypeInfo<T extends FieldType> {
  const FieldTypeInfo();

  static FieldTypeInfo of(FieldType type, {required InputOptions options}) {
    return switch (type) {
      BoolType() => const BoolTypeInfo(),
      IntType() => const IntTypeInfo(),
      DoubleType() => const DoubleTypeInfo(),
      StringType() => const StringTypeInfo(),

      ListType(elementType: final elementType) => ListTypeInfo(
        FieldTypeInfo.of(elementType, options: options) as ListableTypeInfo,
      ),

      StructType() => StructTypeInfo(structType: type, options: options),

      _ => throw ArgumentError(
        "Can't map out-of-library field type ${type.runtimeType}",
      ),
    };
  }

  String get dartName;

  String dartConvertFieldToNative(String dartField) => dartField;

  List<String> dartAssignFieldToNative(String name) {
    return ['$name = ${dartConvertFieldToNative(name)}'];
  }

  String dartConvertFieldFromNative(String nativeField) => nativeField;

  List<String> cDeclareInStruct(String name);
  List<String> cCallFreeFunction(String variable);
}

base mixin ListableTypeInfo<T extends FieldType> on FieldTypeInfo<T> {
  @override
  List<String> cDeclareInStruct(String name) => ['$cName $name'];

  @override
  List<String> cCallFreeFunction(String variable) => [];

  String get cName;
}

final class BoolTypeInfo extends FieldTypeInfo<BoolType> with ListableTypeInfo {
  const BoolTypeInfo();

  @override
  final String dartName = 'bool';
  @override
  final String cName = 'bool';
}

final class IntTypeInfo extends FieldTypeInfo<IntType> with ListableTypeInfo {
  const IntTypeInfo();

  @override
  final String dartName = 'int';
  @override
  final String cName = 'int32_t';
}

final class DoubleTypeInfo extends FieldTypeInfo<DoubleType>
    with ListableTypeInfo {
  const DoubleTypeInfo();

  @override
  final String dartName = 'double';
  @override
  final String cName = 'double';
}

final class StringTypeInfo extends FieldTypeInfo<StringType>
    with ListableTypeInfo {
  const StringTypeInfo();

  @override
  final String dartName = 'String';

  @override
  String dartConvertFieldToNative(String dartField) =>
      '$dartField.toNative(arena)';

  @override
  String dartConvertFieldFromNative(String nativeField) =>
      '$nativeField.toDart()';

  @override
  final String cName = 'char*';

  @override
  List<String> cCallFreeFunction(String variable) => ['freeString($variable)'];
}

final class ListTypeInfo extends FieldTypeInfo<ListType> {
  final ListableTypeInfo elementTypeInfo;

  const ListTypeInfo(this.elementTypeInfo);

  @override
  String get dartName => 'List<${elementTypeInfo.dartName}>';

  @override
  String dartConvertFieldToNative(String dartField) =>
      '$dartField.toNative((e) => ${elementTypeInfo.dartConvertFieldToNative('e')})';

  @override
  List<String> dartAssignFieldToNative(String name) => [
    '${name}_count = $name.length',
    '$name = ${dartConvertFieldToNative(name)}',
  ];

  @override
  String dartConvertFieldFromNative(String nativeField) =>
      '$nativeField.toList(${nativeField}_count, (e) => ${elementTypeInfo.dartConvertFieldFromNative('e')})';

  @override
  List<String> cDeclareInStruct(String name) => [
    'size_t ${name}_count',
    '${elementTypeInfo.cName}* $name',
  ];

  @override
  List<String> cCallFreeFunction(String variable) => switch (elementTypeInfo) {
    StringTypeInfo() => ['freeStringArray($variable, ${variable}_count)'],

    StructTypeInfo(structType: final structType, options: final options) => [
      'freeArray($variable, ${variable}_count, ${options.renameStructFreeFunctionInternal(structType.name)})',
    ],

    _ => ['freeArray($variable)'],
  };
}

final class StructTypeInfo extends FieldTypeInfo<StructType>
    with ListableTypeInfo {
  final StructType structType;
  final InputOptions options;

  const StructTypeInfo({required this.structType, required this.options});

  @override
  String get dartName => structType.name;

  @override
  String dartConvertFieldToNative(String dartField) => '$dartField.toNative()';

  @override
  List<String> dartAssignFieldToNative(String name) => [
    '$name = ${dartConvertFieldToNative(name)}',
  ];

  @override
  String dartConvertFieldFromNative(String nativeField) =>
      '$nativeField.toDart()';

  @override
  String get cName => options.renameStructInC(structType.name);

  @override
  List<String> cCallFreeFunction(String variable) {
    final freeFunctionName = options.renameStructFreeFunctionInternal(
      structType.name,
    );

    return ['$freeFunctionName($variable)'];
  }
}
