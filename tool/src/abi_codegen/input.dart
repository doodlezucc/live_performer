class Input {
  final Files files;
  final InputOptions options;
  final Map<String, StructDefinition> structs;

  const Input({
    required this.files,
    required this.options,
    required this.structs,
  });
}

class Files {
  final Uri entrypointHeaderFile;

  final Uri generatedCHeaderFile;
  final Uri generatedCppFile;
  final Uri generatedDartFile;

  Files({
    required this.entrypointHeaderFile,
    required this.generatedCHeaderFile,
    required this.generatedCppFile,
    required this.generatedDartFile,
  });
}

class InputOptions {
  final String preambleCHeader;
  final String preambleCpp;
  final String preambleDart;

  final String abiExportMacroName;

  final String Function(String structName) renameStructInC;
  final String Function(String structName) renameStructFreeFunction;
  final String Function(String structName) renameStructFreeFunctionInternal;

  InputOptions({
    required this.preambleCHeader,
    required this.preambleCpp,
    required this.preambleDart,
    required this.abiExportMacroName,
    required this.renameStructInC,
    required this.renameStructFreeFunction,
    required this.renameStructFreeFunctionInternal,
  });
}

class StructDefinition {
  final Map<String, FieldType> fields;

  const StructDefinition(this.fields);
}

sealed class FieldType {
  const FieldType();

  static const bool = BoolType();
  static const int = IntType();
  static const double = DoubleType();
  static const string = StringType();

  static StructType struct(String name) => StructType(name);
}

mixin ListableType on FieldType {
  ListType get list => ListType(this);
}

class BoolType extends FieldType with ListableType {
  const BoolType();
}

class IntType extends FieldType with ListableType {
  const IntType();
}

class DoubleType extends FieldType with ListableType {
  const DoubleType();
}

class StringType extends FieldType with ListableType {
  const StringType();
}

class ListType extends FieldType {
  final FieldType elementType;

  const ListType(this.elementType);
}

class StructType extends FieldType with ListableType {
  final String name;

  const StructType(this.name);
}
