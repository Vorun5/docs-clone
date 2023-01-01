import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  void setToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('x-auth-token');
    
    return token;
  }
}