import 'dart:ffi';

import 'package:ffi/ffi.dart';

extension StringToNative on String {
  Pointer<Char> toNative(Arena arena) =>
      toNativeUtf8(allocator: arena).cast<Char>();
}

extension StructListToNative<E> on List<E> {
  Pointer<T> toNative<T extends Struct>(
    Pointer<T> Function(int size) allocator,
    T Function(E e) mapElementToNative,
  ) {
    final pointer = allocator(length);

    for (var i = 0; i < length; i++) {
      pointer[i] = mapElementToNative(this[i]);
    }

    return pointer;
  }
}
