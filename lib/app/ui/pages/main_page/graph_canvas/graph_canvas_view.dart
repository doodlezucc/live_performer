import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_performer/app/data/app_state.dart';
import 'package:live_performer/app/data/blocs/graph.dart';
import 'package:live_performer/app/data/blocs/graph_group.dart';

import 'graph_canvas.dart';

class GraphCanvasView extends StatelessWidget {
  const GraphCanvasView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GraphBloc(repository: getIt())..initialize(),
      child: BlocBuilder<GraphBloc, GraphState>(
        bloc: context.read(),
        builder: (context, state) => switch (state) {
          GraphInitial() => Center(child: Text('Initializing graph...')),

          GraphReady() => BlocProvider(
            create: (context) =>
                GraphGroupBloc(graph: context.read(), groupId: null),
            child: BlocBuilder<GraphGroupBloc, GraphGroupState>(
              bloc: context.read(),
              builder: (context, state) => GraphCanvas(nodes: state.nodes),
            ),
          ),
        },
      ),
    );
  }
}
