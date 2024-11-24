import 'package:flutter/material.dart';

class DockItem extends StatefulWidget {
  final Function(IconData) onTap;
  final IconData icon;
  final bool isInstalling;
  final Color color;
  final VoidCallback? onCancelInstallation;
  final bool isDropAnimating;

  const DockItem({
    super.key,
    required this.icon,
    required this.color,
    this.isInstalling = false,
    this.onCancelInstallation,
    required this.onTap,
    this.isDropAnimating = false,
  });

  @override
  State<DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<DockItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  double _installProgress = 0.0;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _springController;
  Offset? _dragStartPosition;
  Offset? _dragEndPosition;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<IconData>(
      data: widget.icon,
      onDragStarted: () {
        final RenderBox box = context.findRenderObject() as RenderBox;
        setState(() {
          _dragStartPosition = box.localToGlobal(Offset.zero);
        });
      },
      onDraggableCanceled: (velocity, offset) {
        if (_dragStartPosition != null) {
          setState(() {
            _dragEndPosition = offset;
          });

          _springController.reset();
          _springController.forward().then((_) {
            setState(() {
              _dragStartPosition = null;
              _dragEndPosition = null;
            });
          });
        }
      },
      feedback: AnimatedBuilder(
        animation: _springController,
        builder: (context, child) {
          if (_dragStartPosition == null || _dragEndPosition == null) {
            return _buildIcon();
          }

          final springCurve = CurvedAnimation(
            parent: _springController,
            curve: Curves.elasticOut,
          );

          final currentOffset = Offset.lerp(
            _dragEndPosition! - _dragStartPosition!,
            Offset.zero,
            springCurve.value,
          );

          return Transform.translate(
            offset: currentOffset ?? Offset.zero,
            child: _buildIcon(),
          );
        },
      ),
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _bounceController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _bounceController.reverse();
        },
        child: GestureDetector(
          onTap: () => widget.onTap(widget.icon),
          child: _buildMainIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(widget.icon, color: Colors.white),
      ),
    );
  }

  Widget _buildMainIcon() {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isInstalling ? 0.7 : 1.0,
        child: Container(
          width: _isHovered ? 56 : 48,
          height: _isHovered ? 56 : 48,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.color,
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isInstalling)
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, widget.color],
                      stops: [0.0, _installProgress],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: _isHovered ? 32 : 24,
                  ),
                )
              else
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: _isHovered ? 32 : 24,
                ),
              if (widget.isInstalling)
                CircularProgressIndicator(
                  value: _installProgress,
                  color: Colors.white.withOpacity(0.8),
                  strokeWidth: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _springController.dispose();
    super.dispose();
  }
}