import 'package:flutter/material.dart';

class ZoomWrapper extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final double initialScale;

  const ZoomWrapper({
    super.key,
    required this.child,
    this.minScale = 0.8,
    this.maxScale = 4.0,
    this.initialScale = 1.0,
  });

  @override
  _ZoomWrapperState createState() => _ZoomWrapperState();
}

class _ZoomWrapperState extends State<ZoomWrapper> {
  late TransformationController _transformationController;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _currentScale = widget.initialScale;
    _transformationController.value = Matrix4.identity()..scale(_currentScale);
    _transformationController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale * 1.2).clamp(widget.minScale, widget.maxScale);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale / 1.2).clamp(widget.minScale, widget.maxScale);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = widget.initialScale;
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  bool get _isZoomed {
    return (_currentScale - widget.initialScale).abs() > 0.01;
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          panEnabled: true,
          transformationController: _transformationController,
          boundaryMargin: EdgeInsets.all(20),
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          child: widget.child,
        ),
        if (_isZoomed)
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  onPressed: _zoomIn,
                  mini: true,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  onPressed: _zoomOut,
                  mini: true,
                  child: Icon(Icons.remove),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'reset_zoom',
                  onPressed: _resetZoom,
                  mini: true,
                  child: Icon(Icons.refresh),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
