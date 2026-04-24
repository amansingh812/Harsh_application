import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:school_scout/constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/encryption_logic.dart';

class RefreshTokenService {
  static const _storage = FlutterSecureStorage();
  static bool _isRefreshing = false;
  static Future<bool>? _refreshFuture;

  static Future<bool> refresh() {
    _refreshFuture ??= _doRefresh().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  static Future<bool> _doRefresh() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) return false;
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('phoneNumber');
      final response = await dio.post(
        ApiEndpoints.accessToken,
        data: EncryptionUtils.encrypt(jsonEncode({
          "refreshToken": refreshToken,
          "mobNumber": phone,
        })),
        options: Options(
          headers: {'Content-Type': 'text/plain'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      final encrypted = normalizeEncrypted(response.data);
      final decrypted = EncryptionUtils.decrypt(encrypted);

      final decoded = jsonDecode(decrypted);

      if (decoded['statusCode'] == "01") {
        await _storage.deleteAll();
        return false;
      }

      await _storage.write(key: 'accessToken', value: decoded['accessToken']);
      await _storage.write(key: 'refreshToken', value: decoded['refreshToken']);
      return true;
    } catch (e) {
      print("REFRESH ERROR => $e");
      return false;
    }
  }
}

String normalizeEncrypted(dynamic data) {
  if (data is String) {
    return data.replaceAll('"', '').trim();
  }
  if (data is List<int>) {
    return utf8.decode(data);
  }
  return data.toString();
}
