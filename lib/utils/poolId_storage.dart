import 'package:shared_preferences/shared_preferences.dart';

class PoolIdStorage {
  static Future<void> savePoolId(String poolId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("pool_id", poolId);
  }

  static Future<String?> getPoolId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("pool_id");
  }

  static Future<void> clearPoolId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("pool_id");
  }
}