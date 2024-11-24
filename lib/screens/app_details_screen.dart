import 'package:flutter/material.dart';

class AppDetailsScreen extends StatelessWidget {
  final IconData icon;
  final Color color;

  const AppDetailsScreen({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: color,
            ),
            const SizedBox(height: 20),
            Text(
              'App with icon: ${icon.toString()}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}