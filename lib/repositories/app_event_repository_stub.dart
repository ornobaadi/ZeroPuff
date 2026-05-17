import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_event.dart';

final appEventRepositoryProvider = Provider<AppEventRepository>((ref) {
  return AppEventRepository();
});

class AppEventRepository {
  final List<AppEvent> events = [];

  Future<void> track(AppEvent event) async {
    events.add(event);
  }
}
