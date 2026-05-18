import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

class AccountRepository {
  Future<void> deleteLocalData() async {}
}
