import 'dart:collection';

import 'package:flutter/material.dart';

class GraphGroupState {
  final Set<GraphNode> _nodes = {};
  late final nodes = UnmodifiableSetView(_nodes);
}

class GraphNode {
  final int id;
  Offset offset;

  GraphNode({required this.id, required this.offset});
}
