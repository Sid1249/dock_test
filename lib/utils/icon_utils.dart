import 'package:flutter/material.dart';

final Map<IconData, Color> iconColors = {};

void initializeIconColors(List<IconData> icons) {
  for (var icon in icons) {
    if (!iconColors.containsKey(icon)) {
      iconColors[icon] = Colors.primaries[icon.hashCode % Colors.primaries.length];
    }
  }
}