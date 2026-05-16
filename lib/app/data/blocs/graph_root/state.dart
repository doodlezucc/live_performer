import 'package:live_performer/mixer_engine/mixer_engine.dart';

sealed class GraphRootState {}

final class GraphRootInitial extends GraphRootState {}

final class GraphRootReady extends GraphRootState {
  final GraphIONodeInfo ioNodeInfo;

  GraphRootReady({required this.ioNodeInfo});
}
