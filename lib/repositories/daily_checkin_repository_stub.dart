import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'daily_checkin_repository.dart';

DailyCheckInRepository getDailyCheckInRepository(Ref ref) {
  return DailyCheckInRepositoryStub();
}

class DailyCheckInRepositoryStub implements DailyCheckInRepository {
  static final Map<String, DailyCheckInRecord> _records = {};

  @override
  Future<DailyCheckInRecord?> getToday() async {
    return _records[localDateKey(DateTime.now())];
  }

  @override
  Future<List<DailyCheckInRecord>> getRecent({int limit = 14}) async {
    final rows = _records.values.toList()
      ..sort((a, b) => b.localDate.compareTo(a.localDate));
    return rows.take(limit).toList();
  }

  @override
  Future<DailyCheckInRecord> saveToday({
    required int mood,
    required bool smokeFreeToday,
    required int cigarettesSmoked,
    String? note,
  }) async {
    final now = DateTime.now();
    final localDate = localDateKey(now);
    final existing = _records[localDate];
    final record = DailyCheckInRecord(
      checkInId: existing?.checkInId ?? const Uuid().v4(),
      localDate: localDate,
      mood: mood,
      smokeFreeToday: smokeFreeToday,
      cigarettesSmoked: cigarettesSmoked,
      note: note,
      createdAt: now,
    );
    _records[localDate] = record;
    return record;
  }
}
