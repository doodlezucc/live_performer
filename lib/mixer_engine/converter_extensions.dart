import 'dart:ffi';

import 'package:ffi/ffi.dart';

extension StringToNative on String {
  Pointer<Char> toUtf8(Arena arena) =>
      toNativeUtf8(allocator: arena).cast<Char>();
}

extension CharPointerToString on Pointer<Char> {
  String toDart() => cast<Utf8>().toDartString();
}

extension ListToNative<E> on List<E> {
  Pointer<T> toNativeArray<T extends SizedNativeType>(
    Pointer<T> Function(int size) allocator,
    void Function(Pointer<T> pointer, int i, E e) mapElementToNative,
  ) {
    final pointer = allocator(length);

    for (var i = 0; i < length; i++) {
      mapElementToNative(pointer, i, this[i]);
    }

    return pointer;
  }
}

extension StringListToNative on List<String> {
  Pointer<Pointer<Char>> toUtf8Array(Arena arena) {
    final pointer = arena<Pointer<Char>>(length);

    for (var i = 0; i < length; i++) {
      pointer[i] = this[i].toUtf8(arena);
    }

    return pointer;
  }
}

extension PointerToList<E extends SizedNativeType> on Pointer<E> {
  List<T> toList<T>(int length, T Function(Pointer<E>, int i) mapToDart) {
    return List.generate(length, (i) => mapToDart(this, i));
  }
}
