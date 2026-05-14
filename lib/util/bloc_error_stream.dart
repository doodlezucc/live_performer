import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin BlocErrorStream<State> on BlocBase<State> {
  final _errors = StreamController<Object>.broadcast();
  Stream<Object> get errors => _errors.stream;

  @override
  @protected
  void onError(Object error, StackTrace stackTrace) {
    _errors.add(error);
    super.onError(error, stackTrace);
  }
}
