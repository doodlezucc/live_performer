import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/blocs/graph.dart';

import 'state.dart';

class GraphGroupBloc extends Cubit<GraphGroupState> {
  GraphGroupBloc({required this.graph, required this.groupId})
    : super(GraphGroupState.fromGraph(graph.state, groupId: groupId)) {
    // Start reacting to graph updates
    _graphSubscription = graph.stream.listen((state) {
      emit(_inferStateFromGraph(state));
    });
  }

  // Strictly speaking, this is heavily discouraged by the bloc documentation,
  // but honestly, some people disagree with good arguments.
  // And it's just so comfortable.
  final GraphBloc graph;
  final int? groupId;
  late StreamSubscription _graphSubscription;

  @override
  Future<void> close() async {
    // Stop reacting to graph updates
    await _graphSubscription.cancel();
    return super.close();
  }

  GraphGroupState _inferStateFromGraph(GraphState graphState) {
    return GraphGroupState.fromGraph(graphState, groupId: groupId);
  }
}
