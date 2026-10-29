import 'package:shared_preferences/shared_preferences.dart';

abstract interface class FocusRepository {
  Future<String?> read();
  Future<void> write(String data);
}

class LocalRepository implements FocusRepository {
  LocalRepository(this.preferences);
  final SharedPreferences preferences;
  static const key = 'focus.state.v1';

  @override
  Future<String?> read() async => preferences.getString(key);

  @override
  Future<void> write(String data) async {
    if (!await preferences.setString(key, data)) {
      throw StateError('No se pudieron guardar los datos');
    }
  }
}
