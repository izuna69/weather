import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _key = 'favoriteRegions';

  static Future<void> saveFavorites(List<String> regions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, regions);
  }

  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
