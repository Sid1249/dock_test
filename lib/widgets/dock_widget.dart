import 'package:flutter/material.dart';
import 'package:mac_docker_test/themes/dock_theme.dart';
import '../utils/icon_utils.dart';

class Dock extends StatefulWidget {
  final List<IconData> items;
  final Widget Function(IconData) builder;
  final Function(IconData, int) onInsert;
  final Function(int, int) onReorder;
  final Function(IconData) onTap;

  const Dock({
    super.key,
    required this.items,
    required this.builder,
    required this.onInsert,
    required this.onReorder,
    required this.onTap,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  double? _mouseX;
  int? _insertIndex;
  bool _isDragging = false;
  final double BASE_SIZE = 48.0;
  final double MAX_SIZE = 59.0;
  Set<IconData> _droppingItems = {};
  int? _currentDragStartIndex;

  @override
  void initState() {
    super.initState();
  }

  void _updateMousePosition(Offset position) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(position);
    setState(() {
      _mouseX = localPosition.dx;
    });
  }

  @override
  void didUpdateWidget(Dock oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  double _getSize(double distance, int index) {
    if (_mouseX == null) return BASE_SIZE;

    final centerX = (BASE_SIZE + 16) * index + BASE_SIZE / 2;
    distance = (centerX - _mouseX!).abs();

    const double DISTANCE_THRESHOLD = 150.0;
    if (distance > DISTANCE_THRESHOLD) return BASE_SIZE;

    double scale = 1 - (distance * distance) / (DISTANCE_THRESHOLD * DISTANCE_THRESHOLD);
    scale = scale.clamp(0.0, 1.0);
    return BASE_SIZE + (MAX_SIZE - BASE_SIZE) * scale;
  }

  void _handleDragStart(int index) {
    setState(() {
      _currentDragStartIndex = index;
      print("_currentDragStartIndex: $_currentDragStartIndex");
      _isDragging = true;
    });
  }

  void _updateInsertIndex(DragTargetDetails<IconData> details, int itemIndex) {
    _updateMousePosition(details.offset);

    if (!_isDragging) {
      setState(() {
        widget.items.remove(details.data);
        _isDragging = true;
      });
    }

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.offset);
    final dx = localPosition.dx;

    if (dx < BASE_SIZE) {
      setState(() {
        _insertIndex = 0;
      });
      return;
    }

    final itemWidth = (BASE_SIZE + 16);
    final relativeX = dx % itemWidth;
    final newIndex = relativeX < itemWidth / 2 ? itemIndex : itemIndex + 1;

    setState(() {
      _insertIndex = newIndex;
    });
  }

  void _handleDrop(IconData draggedIcon, int targetIndex) {

    setState(() {
      _isDragging = false;
      _droppingItems.add(draggedIcon);
      _mouseX = null;
    });



    if ((_insertIndex == null || targetIndex < 0 || targetIndex > widget.items.length)) {
      if (_currentDragStartIndex != null) {
        setState(() {
          if (!widget.items.contains(draggedIcon)) {
            widget.items.insert(_currentDragStartIndex!, draggedIcon);
          }
          _insertIndex = null;
          _isDragging = false;
          _currentDragStartIndex = null;
        });
      }
      return;
    }

    if (widget.items.contains(draggedIcon)) {
      widget.onReorder(widget.items.indexOf(draggedIcon), targetIndex);
    } else {
      widget.onInsert(draggedIcon, targetIndex);
    }

    if (mounted) {
      setState(() {
        _droppingItems.remove(draggedIcon);
        _insertIndex = null;
        _isDragging = false;
        _currentDragStartIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dockTheme = Theme.of(context).extension<DockTheme>()!;

    return MouseRegion(
      onExit: (event) => setState(() => _mouseX = null),
      onHover: (event) => _updateMousePosition(event.position),
      child: Listener(
        onPointerMove: (event) => _updateMousePosition(event.position),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: dockTheme.borderRadius,
            color: dockTheme.dockColor.withOpacity(dockTheme.backgroundOpacity),
          ),
          padding: dockTheme.padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DragTarget<IconData>(
                onWillAccept: (data) => true,
                onAcceptWithDetails: (details) {
                  _handleDrop(details.data, 0);
                  setState(() {
                    _isDragging = false;
                    _insertIndex = null;
                  });
                },
                onMove: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.offset);

                  if (localPosition.dx < BASE_SIZE) {
                    setState(() {
                      _insertIndex = 0;
                      _isDragging = true;
                    });
                  }
                },
                onLeave: (_) => setState(() {
                  if (_insertIndex == 0) {
                    _insertIndex = null;
                    _isDragging = false;
                  }
                }),
                builder: (context, candidates, rejects) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: dockTheme.animationDuration,
                      curve: dockTheme.animationCurve,
                      width: _insertIndex == 0 ? MAX_SIZE : 0,
                      height: MAX_SIZE,
                      margin: EdgeInsets.symmetric(
                          horizontal: _insertIndex == 0 ? 4 : 0
                      ),
                    ),
                  );
                },
              ),

              ...widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final icon = entry.value;

                double centerX = (BASE_SIZE + 16) * index + BASE_SIZE / 2;
                double distance = _mouseX == null ? double.infinity :
                (centerX - _mouseX!).abs();
                double size = _getSize(distance, index);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isDragging && index > 0)
                      DragTarget<IconData>(
                        onWillAccept: (data) => true,
                        onAcceptWithDetails: (details) {
                          _handleDrop(details.data, index);
                        },
                        onMove: (details) {
                          setState(() {
                            if(index == 0){
                              _insertIndex = index - 1;
                            }
                            _insertIndex = index;
                            _isDragging = true;
                          });
                        },
                        onLeave: (_) => setState(() {
                          if (_insertIndex == index) {
                            _insertIndex = null;
                            _isDragging = false;
                          }
                        }),
                        builder: (context, candidates, rejects) {
                          return AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration: dockTheme.animationDuration,
                              curve: dockTheme.animationCurve,
                              width: _insertIndex == index ? MAX_SIZE : 0,
                              height: MAX_SIZE,
                              margin: EdgeInsets.symmetric(
                                  horizontal: _insertIndex == index ? 4 : 0
                              ),
                            ),
                          );
                        },
                      ),

                    DragTarget<IconData>(
                      onWillAccept: (data) => true,
                      onAcceptWithDetails: (details) {
                        _handleDrop(details.data, index);
                      },
                      onMove: (details) => _updateInsertIndex(details, index),
                      onLeave: (_) => setState(() {
                        _insertIndex = null;
                        _isDragging = false;
                      }),
                      builder: (context, candidates, rejects) {
                        return AnimatedContainer(
                          duration: dockTheme.animationDuration,
                          curve: dockTheme.animationCurve,
                          width: size,
                          height: size,
                          margin: EdgeInsets.only(
                            bottom: (size - BASE_SIZE) / 2,
                            left: 8,
                            right: 8,
                          ),
                          child: LongPressDraggable<IconData>(
                            data: icon,
                            delay: Duration(milliseconds: 200),
                            onDragStarted: () => _handleDragStart(index),
                            onDraggableCanceled: (velocity, offset) {
                              if (_currentDragStartIndex != null) {
                                setState(() {
                                  if (!widget.items.contains(icon)) {
                                    widget.items.insert(_currentDragStartIndex!, icon);
                                  }
                                  _insertIndex = null;
                                  _isDragging = false;
                                  _currentDragStartIndex = null;
                                });
                              }
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: AnimatedContainer(
                                width: MAX_SIZE,
                                height: MAX_SIZE,
                                decoration: BoxDecoration(
                                  color: iconColors[icon],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: Duration(seconds: 1),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: MAX_SIZE * 0.6,
                                ),
                              ),
                            ),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: 1,
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  color: iconColors[icon],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      icon,
                                      color: Colors.white,
                                      size: size * 0.6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),

              DragTarget<IconData>(
                onWillAccept: (data) => true,
                onAcceptWithDetails: (details) {
                  _handleDrop(details.data, widget.items.length);
                },
                onMove: (details) {
                  setState(() {
                    _insertIndex = widget.items.length;
                    _isDragging = true;
                  });
                },
                onLeave: (_) => setState(() {
                  if (_insertIndex == widget.items.length) {
                    _insertIndex = null;
                    _isDragging = false;
                  }
                }),
                builder: (context, candidates, rejects) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _insertIndex == widget.items.length ? MAX_SIZE : 0,
                    height: MAX_SIZE,
                    margin: EdgeInsets.symmetric(
                        horizontal: _insertIndex == widget.items.length ? 4 : 0
                    ),
                  );
                },
              ),
            ],
          ),),
      ),
    );
  }
}