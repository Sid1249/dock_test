import 'package:flutter/material.dart';

@immutable
class DockTheme extends ThemeExtension<DockTheme> {
  final Color backgroundColor;
  final Color dockColor;

  final double backgroundOpacity;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Duration animationDuration;
  final Curve animationCurve;

  const DockTheme({
    required this.backgroundColor,
    required this.backgroundOpacity,
    required this.borderRadius,
    required this.padding,
    required this.animationDuration,
    required this.animationCurve, required  this.dockColor,
  });

  @override
  DockTheme copyWith({
    Color? backgroundColor,
    Color? dockColor,
    double? backgroundOpacity,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return DockTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dockColor: dockColor ?? this.dockColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  ThemeExtension<DockTheme> lerp(ThemeExtension<DockTheme>? other, double t) {
    if (other is! DockTheme) return this;

    return DockTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      backgroundOpacity: lerpDouble(backgroundOpacity, other.backgroundOpacity, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      animationDuration: Duration(
        milliseconds: lerpDouble(
          animationDuration.inMilliseconds.toDouble(),
          other.animationDuration.inMilliseconds.toDouble(),
          t,
        ).round(),
      ),
      animationCurve: animationCurve, dockColor: Color.lerp(dockColor, other.backgroundColor, t)!,
    );
  }

  static const light = DockTheme(
    backgroundColor: Colors.white,
    backgroundOpacity: 0.2,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    animationDuration: Duration(milliseconds: 200),
    animationCurve: Curves.easeOutCubic,
      dockColor: Colors.black38,
  );

  static const dark = DockTheme(
    backgroundColor: Colors.black,
    backgroundOpacity: 0.2,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    animationDuration: Duration(milliseconds: 200),
    animationCurve: Curves.easeOutCubic,
    dockColor: Colors.white24
  );
}

double lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}