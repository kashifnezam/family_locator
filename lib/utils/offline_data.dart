import 'package:shared_preferences/shared_preferences.dart';

class OfflineData {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  static Future<String?> getData(String key) async {
    return await asyncPrefs.getString(key);
  }

  static void setData(String key, String value, bool type) async {
    asyncPrefs.setString("date", DateTime.now().toString());
    asyncPrefs.setBool("temp", type);
    return asyncPrefs.setString(key, value);
  }
}
