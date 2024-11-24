import 'package:flutter/material.dart';
import 'package:mac_docker_test/widgets/dock_item.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../widgets/dock_widget.dart';
import '../widgets/feature_list.dart';
import '../utils/icon_utils.dart';
import '../widgets/installable_app.dart';
import 'app_details_screen.dart';

class DockScreen extends StatefulWidget {
  @override
  _DockScreenState createState() => _DockScreenState();
}

class _DockScreenState extends State<DockScreen> {
  final List<IconData> dockItems = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.music_note,
    Icons.movie,
  ];

  List<IconData> installableItems = [
    Icons.games,
    Icons.book,
  ];

  @override
  void initState() {
    super.initState();
    initializeIconColors([...dockItems, ...installableItems]);
  }

  void addItemToDock(IconData icon, int index) {
    setState(() {
      dockItems.insert(index, icon);
      installableItems.remove(icon);
    });
  }

  void _handleAppTap(IconData icon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppDetailsScreen(
          icon: icon,
          color: iconColors[icon]!,
        ),
      ),
    );
  }

  void reorderDockItems(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final IconData item = dockItems.removeAt(oldIndex);
      dockItems.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            themeProvider.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
      ),
      body: Stack(
        children: [
          const FeatureList(),
          Positioned(
            right: 20,
            top: 100,
            child: Column(
              children: installableItems
                  .map((icon) => InstallableApp(
                icon: icon,
                color: iconColors[icon]!,
              ))
                  .toList(),
            ),
          ),
          Center(
            child: Dock(
              items: dockItems,
              onInsert: addItemToDock,
              onReorder: reorderDockItems,
              onTap: _handleAppTap,
              builder: (IconData e) => DockItem(
                icon: e,
                color: iconColors[e]!,
                onTap: _handleAppTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}