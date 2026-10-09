/// One answer to the question asked when a day is sealed.
class SealTag {
  const SealTag(this.value, this.label);

  /// Stored on the day; stable across wording changes.
  final String value;
  final String label;
}

/// The single follow-up asked when a day is sealed. Which one depends on how
/// the day went, so the answers say what works for this person.
class SealQuestion {
  const SealQuestion({required this.title, required this.options});

  final String title;
  final List<SealTag> options;

  static const helped = SealQuestion(
    title: 'What helped you through?',
    options: [
      SealTag('breathing', 'Breathing'),
      SealTag('kept_busy', 'Kept busy'),
      SealTag('water', 'Water'),
      SealTag('moved', 'Moved around'),
      SealTag('talked', 'Talked to someone'),
      SealTag('my_reason', 'Remembered my reason'),
    ],
  );

  static const easier = SealQuestion(
    title: 'What made today easier?',
    options: [
      SealTag('kept_busy', 'Kept busy'),
      SealTag('slept_well', 'Slept well'),
      SealTag('avoided_triggers', 'Avoided my triggers'),
      SealTag('good_company', 'Good company'),
      SealTag('exercise', 'Exercise'),
      SealTag('felt_strong', 'Just felt strong'),
    ],
  );

  static const hard = SealQuestion(
    title: 'What made it hard?',
    options: [
      SealTag('stress', 'Stress'),
      SealTag('boredom', 'Boredom'),
      SealTag('around_smokers', 'Around smokers'),
      SealTag('alcohol', 'Alcohol'),
      SealTag('tired', 'Tired'),
      SealTag('after_meal', 'After a meal'),
      SealTag('argument', 'An argument'),
    ],
  );

  /// The question that fits the day.
  static SealQuestion forDay({required int beaten, required bool slipped}) {
    if (slipped) {
      return hard;
    }
    return beaten > 0 ? helped : easier;
  }

  /// Tags that describe something that worked, as opposed to what got in the
  /// way.
  static final Set<String> helpfulValues = {
    for (final tag in [...helped.options, ...easier.options]) tag.value,
  };

  static String labelFor(String value) {
    for (final tag in [...helped.options, ...easier.options, ...hard.options]) {
      if (tag.value == value) {
        return tag.label;
      }
    }
    return value;
  }
}

/// How a day felt, from hardest (1) to clearest (5).
class DayFeeling {
  const DayFeeling(this.value, this.label);

  final int value;
  final String label;

  static const all = [
    DayFeeling(1, 'Hard'),
    DayFeeling(2, 'Unsettled'),
    DayFeeling(3, 'Managing'),
    DayFeeling(4, 'Steady'),
    DayFeeling(5, 'Clear'),
  ];

  static String? labelFor(int? value) {
    for (final feeling in all) {
      if (feeling.value == value) {
        return feeling.label;
      }
    }
    return null;
  }
}
