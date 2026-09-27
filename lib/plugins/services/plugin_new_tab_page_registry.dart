import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otzaria/navigation/bloc/navigation_bloc.dart';
import 'package:otzaria/navigation/bloc/navigation_event.dart';
import 'package:otzaria/navigation/bloc/navigation_state.dart';
import 'package:otzaria/plugins/plugin_constants.dart';
import 'package:otzaria/plugins/services/plugin_page_launcher.dart';

/// Controls what the reader's "+" (new tab) button opens.
///
/// With no plugin contribution the built-in library is always used. A plugin
/// may register its own page as the target; registrations are tied to a live
/// plugin instance and disappear when that instance is disposed.
class PluginNewTabPageRegistry {
  static final PluginNewTabPageRegistry instance = PluginNewTabPageRegistry._();
  PluginNewTabPageRegistry._();

  final Map<PluginInstanceKey, int> _registrations = {};
  int _sequence = 0;

  void register(String pluginId, {required String instanceId}) {
    _registrations[(pluginId: pluginId, instanceId: instanceId)] = ++_sequence;
  }

  void remove(String pluginId, {required String instanceId}) {
    _registrations.remove((pluginId: pluginId, instanceId: instanceId));
  }

  void removeInstance(PluginInstanceKey key) => _registrations.remove(key);

  String? get activePluginId {
    if (_registrations.isEmpty) return null;
    PluginInstanceKey? selected;
    var newest = -1;
    for (final entry in _registrations.entries) {
      if (entry.value > newest) {
        newest = entry.value;
        selected = entry.key;
      }
    }
    return selected?.pluginId;
  }

  /// Opens the registered plugin page, or the library when none is registered.
  void open(BuildContext context) {
    final pluginId = activePluginId;
    if (pluginId == null) {
      context.read<NavigationBloc>().add(const NavigateToScreen(Screen.library));
      return;
    }
    PluginPageLauncher.instance.open(
      pluginId,
      topic: 'plugin.page_opened',
      payload: const {'source': 'newTabButton'},
    );
  }
}
