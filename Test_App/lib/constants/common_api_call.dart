import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:school_scout/constants/encryption_password.dart';
import 'package:school_scout/global/global_data.dart';
import '../apis/security/secure_http.dart';
import '../apis/service/refresh_token_service.dart';
import '../widgets/session_expired_sheet.dart';
import 'encryption_logic.dart';

class CommonApiCall {
  final String baseUrl;
  final EncryptionUtils encryptionUtils;

  CommonApiCall({required this.baseUrl}) : encryptionUtils = EncryptionUtils();

  String pwd = EncryptionPassword.encryptionPassword;
  final _secureStorage = const FlutterSecureStorage();

  Future<dynamic> post(Map<String, dynamic> body) async {
    try {
      String encryptedBody = EncryptionUtils.encrypt(jsonEncode(body));
      final authToken = await _secureStorage.read(key: 'accessToken');

      if (authToken == null || authToken.isEmpty) {
        SessionExpiredSheet.show();
        throw Exception("Token missing");
      }

      final dio = SecureHttp.create();   // 🔐 SSL PINNED CLIENT

      final response = await dio.post(
        baseUrl,
        data: encryptedBody,
        options: Options(
          headers: {
            'Content-Type': 'text/plain',
            'Authorization': 'Bearer $authToken',
          },
            validateStatus: (status) => status != null && status < 500,
        ),
      );


      String decrypted = EncryptionUtils.decrypt(response.data);
      final decoded = jsonDecode(decrypted);
      /// ✅ SUCCESS
      if (response.statusCode == 200 && decoded['statusCode'] != 401) {
        return decoded;
      }

      /// 🔄 TOKEN EXPIRED (body-level 401)
      if (decoded['statusCode'] == 401) {
        print("Access token expired → refreshing...");

        final refreshed = await RefreshTokenService.refresh();

        if (refreshed) {
          return post(body); // retry same API
        } else {
          SessionExpiredSheet.show();
          throw Exception("Session expired");
        }
      }

      throw Exception('Server error: ${response.statusCode}');
    } on DioException catch (e) {
      print("SSL / Network error: ${e.message}");
      rethrow;
    }
  }
}
