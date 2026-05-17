import 'package:flutter/widgets.dart';

typedef CanvasNodeState = ({Offset offset});

class CanvasNodeController extends ValueNotifier<CanvasNodeState> {
  CanvasNodeController(super.value);
}
