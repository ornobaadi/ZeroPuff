class OnboardingData {
  const OnboardingData({
    this.quitDate,
    this.cigarettesPerDay,
    this.packPrice,
    this.packSize,
    this.currencyCode = 'USD',
    this.currencySymbol = r'$',
    this.triggers = const [],
    this.quitReason,
    this.currentStep = 0,
    this.completed = false,
  });

  final DateTime? quitDate;
  final int? cigarettesPerDay;
  final double? packPrice;
  final int? packSize;
  final String currencyCode;
  final String currencySymbol;
  final List<String> triggers;
  final String? quitReason;
  final int currentStep;
  final bool completed;

  OnboardingData copyWith({
    DateTime? quitDate,
    int? cigarettesPerDay,
    double? packPrice,
    int? packSize,
    String? currencyCode,
    String? currencySymbol,
    List<String>? triggers,
    String? quitReason,
    int? currentStep,
    bool? completed,
  }) {
    return OnboardingData(
      quitDate: quitDate ?? this.quitDate,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      packPrice: packPrice ?? this.packPrice,
      packSize: packSize ?? this.packSize,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      triggers: triggers ?? this.triggers,
      quitReason: quitReason ?? this.quitReason,
      currentStep: currentStep ?? this.currentStep,
      completed: completed ?? this.completed,
    );
  }
}
