import 'dart:convert';

import 'package:parkeer/models/outlet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OutletRepository {
  static const _key = "outlet";

  Future<Outlet> get() async {
    final pref = await SharedPreferences.getInstance();

    final json = pref.getString(_key);

    if (json == null) {
      return Outlet.empty();
    }

    return Outlet.fromJson(jsonDecode(json));
  }

  Future<void> save(Outlet outlet) async {
    final pref = await SharedPreferences.getInstance();

    await pref.setString(_key, jsonEncode(outlet.toJson()));
  }

  Future<void> clear() async {
    final pref = await SharedPreferences.getInstance();

    await pref.remove(_key);
  }
}
