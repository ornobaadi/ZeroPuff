import 'smoking_window_data.dart';

class ProfileData {
  const ProfileData({
    required this.userId,
    required this.displayName,
    required this.quitDate,
    required this.cigarettesPerDay,
    required this.packPrice,
    required this.packSize,
    required this.currencyCode,
    required this.currencySymbol,
    required this.triggers,
    required this.usualSmokingWindow,
    this.avatarUrl,
    this.quitReason,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;
  final DateTime quitDate;
  final int cigarettesPerDay;
  final double packPrice;
  final int packSize;
  final String currencyCode;
  final String currencySymbol;
  final List<String> triggers;
  final SmokingWindowData usualSmokingWindow;
  final String? quitReason;
}
