import 'package:flutter/material.dart';

class FeatureList extends StatelessWidget {
  const FeatureList({super.key});

  final List<String> features = const [
    "Theme Management",
    "Hover to magnify icons",
    "Drag apps from right to install",
    "Reorder dock items",
    "Install apps from right",
    "Smooth insertion animations",
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      top: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: features
              .map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text("• $f", style: const TextStyle(fontSize: 14)),
          ))
              .toList(),
        ),
      ),
    );
  }
}