import '../models/widget_data_model.dart';
import 'widget_updater_interface.dart';

class WidgetUpdateOrchestrator {
  final List<WidgetUpdater> _updaters;

  WidgetUpdateOrchestrator(this._updaters);

  Future<void> dispatchUpdate(WidgetDataModel data) async {
    for (final updater in _updaters) {
      await updater.update(data);
    }
  }
}
