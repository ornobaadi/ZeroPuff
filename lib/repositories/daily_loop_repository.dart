import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/calculations/streak_calculations.dart';

final dailyLoopRepositoryProvider = Provider<DailyLoopRepository>((ref) {
  return const DailyLoopRepository();
});

/// Whether the user has made today's promise.
final pledgedTodayProvider = FutureProvider<bool>((ref) {
  return ref.watch(dailyLoopRepositoryProvider).hasPledgedOn(DateTime.now());
});

final savingsGoalProvider = FutureProvider<SavingsGoal?>((ref) {
  return ref.watch(dailyLoopRepositoryProvider).loadSavingsGoal();
});

/// Something the user is saving their cigarette money towards.
class SavingsGoal {
  const SavingsGoal({required this.name, required this.target});

  final String name;
  final double target;

  /// 0 to 1.
  double progress(double saved) {
    return target <= 0 ? 1 : (saved / target).clamp(0.0, 1.0);
  }

  bool reachedWith(double saved) => saved >= target;
}

/// Small pieces of state behind the daily habit: today's promise and the
/// savings goal. Kept on the device only.
class DailyLoopRepository {
  const DailyLoopRepository();

  static const _pledgeDateKey = 'daily.pledge_date';
  static const _goalNameKey = 'daily.savings_goal_name';
  static const _goalTargetKey = 'daily.savings_goal_target';
  static const _goalCelebratedKey = 'daily.savings_goal_celebrated';
  static const _jarSeenKey = 'daily.jar_seen_money';

  Future<bool> hasPledgedOn(DateTime day) async {
    final store = await SharedPreferences.getInstance();
    return store.getString(_pledgeDateKey) == _dateKey(day);
  }

  Future<void> pledge(DateTime day) async {
    final store = await SharedPreferences.getInstance();
    await store.setString(_pledgeDateKey, _dateKey(day));
  }

  Future<SavingsGoal?> loadSavingsGoal() async {
    final store = await SharedPreferences.getInstance();
    final name = store.getString(_goalNameKey);
    final target = store.getDouble(_goalTargetKey);
    if (name == null || name.isEmpty || target == null || target <= 0) {
      return null;
    }
    return SavingsGoal(name: name, target: target);
  }

  Future<void> saveSavingsGoal(SavingsGoal goal) async {
    final store = await SharedPreferences.getInstance();
    await store.setString(_goalNameKey, goal.name);
    await store.setDouble(_goalTargetKey, goal.target);
  }

  Future<void> clearSavingsGoal() async {
    final store = await SharedPreferences.getInstance();
    await store.remove(_goalNameKey);
    await store.remove(_goalTargetKey);
  }

  Future<bool> hasCelebratedGoal(SavingsGoal goal) async {
    final store = await SharedPreferences.getInstance();
    return store.getString(_goalCelebratedKey) == _goalSignature(goal);
  }

  Future<void> markGoalCelebrated(SavingsGoal goal) async {
    final store = await SharedPreferences.getInstance();
    await store.setString(_goalCelebratedKey, _goalSignature(goal));
  }

  // Changing the goal's name or price makes it a new goal to celebrate.
  String _goalSignature(SavingsGoal goal) => '${goal.name}|${goal.target}';

  /// The money the jar held the last time it was shown, so the coins earned
  /// since then can be dropped in.
  Future<double?> jarSeenMoney() async {
    final store = await SharedPreferences.getInstance();
    return store.getDouble(_jarSeenKey);
  }

  Future<void> setJarSeenMoney(double money) async {
    final store = await SharedPreferences.getInstance();
    await store.setDouble(_jarSeenKey, money);
  }

  /// Removes everything here, for when local data is deleted.
  Future<void> clear() async {
    final store = await SharedPreferences.getInstance();
    await store.remove(_pledgeDateKey);
    await store.remove(_jarSeenKey);
    await store.remove(_goalCelebratedKey);
    await clearSavingsGoal();
  }

  String _dateKey(DateTime day) {
    final date = StreakCalculations.dateOnly(day);
    return '${date.year}-${date.month}-${date.day}';
  }
}
