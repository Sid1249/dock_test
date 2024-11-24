import 'package:flutter/material.dart';
import '../models/dock_item_model.dart';
import '../utils/icon_utils.dart';

class DockProvider extends ChangeNotifier {
  List<IconData> _dockItems = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.music_note,
    Icons.movie,
  ];

  List<IconData> _installableItems = [
    Icons.games,
    Icons.book,
  ];

  List<IconData> get dockItems => _dockItems;
  List<IconData> get installableItems => _installableItems;

  DockProvider() {
    initializeIconColors([..._dockItems, ..._installableItems]);
  }

  void addItemToDock(IconData icon, int index) {
    _dockItems.insert(index, icon);
    _installableItems.remove(icon);
    notifyListeners();
  }

  void reorderDockItems(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final IconData item = _dockItems.removeAt(oldIndex);
    _dockItems.insert(newIndex, item);
    notifyListeners();
  }

  Color getIconColor(IconData icon) {
    return iconColors[icon] ?? Colors.grey;
  }
}