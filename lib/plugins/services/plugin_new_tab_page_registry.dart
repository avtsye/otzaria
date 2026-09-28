import 'package:flutter/foundation.dart';
import 'package:otzaria/plugins/services/plugin_page_launcher.dart';

/// Controls the reader's "+" (new-tab) button.
///
/// The button is disabled/hidden by default. A plugin explicitly enables it
/// through `plugin.setNewTabPage`; the most recent registration becomes the
/// target. Removing the registration hides the button again.
class PluginNewTabPageRegistry extends ChangeNotifier {
  static final PluginNewTabPageRegistry instance = PluginNewTabPageRegistry._();
  PluginNewTabPageRegistry._();

  final Map<String, int> _registrations = {};
  int _sequence = 0;

  bool get hasActiveRegistration => _registrations.isNotEmpty;

  void register(String pluginId) {
    _registrations[pluginId] = ++_sequence;
    notifyListeners();
  }

  void remove(String pluginId) {
    if (_registrations.remove(pluginId) != null) {
      notifyListeners();
    }
  }

  String? get activePluginId {
    if (_registrations.isEmpty) return null;
    String? selected;
    var newest = -1;
    for (final entry in _registrations.entries) {
      if (entry.value > newest) {
        newest = entry.value;
        selected = entry.key;
      }
    }
    return selected;
  }

  void open() {
    final pluginId = activePluginId;
    if (pluginId == null) return;
    PluginPageLauncher.instance.open(
      pluginId,
      topic: 'plugin.page_opened',
      payload: const {'source': 'newTabButton'},
    );
  }
}
