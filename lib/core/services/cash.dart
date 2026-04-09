import 'package:hive_ce_flutter/hive_ce_flutter.dart';

enum Key {
  // userdata,
  userPost,
  userComment,
  userSavedPost,
  blockedUsers,
  themeMode,

  // userCash,
  // settings,
}

class CashService {
  static const String _boxName = 'cashBox';

  static final CashService _instance = CashService._internal();
  factory CashService() => _instance;
  CashService._internal();

  Box? _box;

  /// Initialize Hive CE (call in main.dart before runApp)
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Save data with enum key
  Future<void> save(Key key, dynamic value) async {
    await _box?.put(key.name, value);
  }

  /// Get data with enum key (returns null if none)
  dynamic get(Key key) {
    return _box?.get(key.name);
  }

  /// Check if enum key exists
  bool exist(Key key) {
    return _box?.containsKey(key.name) ?? false;
  }

  // remove all cash
  Future<void> clear() async {
    // Print all keys before clearing
    print('Clearing all cash data:');
    _box?.keys.forEach((key) {
      print('  - $key');
    });
    await _box?.clear();
  }
}
