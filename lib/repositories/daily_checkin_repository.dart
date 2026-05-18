import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_checkin_repository_stub.dart'
    if (dart.library.io) 'daily_checkin_repository_io.dart';

final dailyCheckInRepositoryProvider = Provider<DailyCheckInRepository>((ref) {
  return getDailyCheckInRepository(ref);
});

abstract class DailyCheckInRepository {
  Future<DailyCheckInRecord?> getToday();

  Future<DailyCheckInRecord> saveToday({
    required int mood,
    required bool smokeFreeToday,
    required int cigarettesSmoked,
    String? note,
  });

  Future<List<DailyCheckInRecord>> getRecent({int limit = 14});
}

class DailyCheckInRecord {
  const DailyCheckInRecord({
    required this.checkInId,
    required this.localDate,
    required this.mood,
    required this.smokeFreeToday,
    required this.cigarettesSmoked,
    required this.createdAt,
    this.note,
  });

  final String checkInId;
  final String localDate;
  final int mood;
  final bool smokeFreeToday;
  final int cigarettesSmoked;
  final String? note;
  final DateTime createdAt;
}

String localDateKey(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
