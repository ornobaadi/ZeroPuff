import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityService {
  const DeviceIdentityService._();

  static const _guestIdKey = 'zeropuff.guest_id';
  static const _guestPrefix = 'guest-';

  static String? _guestUserId;

  static String get guestUserId => _guestUserId ?? '${_guestPrefix}device';

  static Future<void> initialize() async {
    if (_guestUserId != null) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_guestIdKey);
    final value = existing ?? const Uuid().v4();

    if (existing == null) {
      await preferences.setString(_guestIdKey, value);
    }

    _guestUserId = '$_guestPrefix$value';
  }
}
