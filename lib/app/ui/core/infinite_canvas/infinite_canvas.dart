import 'package:flutter/material.dart';

class InfiniteCanvas extends StatefulWidget {
  const InfiniteCanvas({
    this.background,
    this.onDoubleTap,
    this.children,
    super.key,
  });

  final Widget? background;
  final void Function(Offset offset)? onDoubleTap;
  final List<Widget>? children;

  @override
  State<InfiniteCanvas> createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  static const _size = Size(100000, 100000);
  static final _center = _size.center(Offset.zero);

  late TransformationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TransformationController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgetCenter = MediaQuery.of(context).size.center(Offset.zero);

    return InteractiveViewer(
      interactionEndFrictionCoefficient: double.minPositive,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      transformationController: _ctrl,
      minScale: 0.2,
      child: Transform.translate(
        offset: -_center + widgetCenter,
        transformHitTests: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.background != null) widget.background!,

            GestureDetector(
              onDoubleTapDown: widget.onDoubleTap != null
                  ? (details) =>
                        widget.onDoubleTap!(details.localPosition - _center)
                  : null,
              behavior: HitTestBehavior.opaque,
              child: SizedBox.fromSize(size: _size),
            ),

            ...(widget.children ?? []),
          ],
        ),
      ),
    );
  }
}
