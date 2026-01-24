import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const _keyName = 'user_name';
  static const _keyBio = 'user_bio';
  static const _keyImagePath = 'user_image';

  static Future<void> saveProfile({
    required String name,
    required String bio,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyBio, bio);
    if (imagePath != null) {
      await prefs.setString(_keyImagePath, imagePath);
    }
  }

  static Future<Map<String, String?>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString(_keyName),
      "bio": prefs.getString(_keyBio),
      "image": prefs.getString(_keyImagePath),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyBio);
    await prefs.remove(_keyImagePath);
  }
}
