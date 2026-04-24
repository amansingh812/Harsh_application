import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_scout/constants/encryption_password.dart';

import 'encryption_logic.dart';

class LoginCommonApiCall {
  final String baseUrl;
  final EncryptionUtils encryptionUtils;

  LoginCommonApiCall({
    required this.baseUrl,
  }) : encryptionUtils = EncryptionUtils();

  String pwd = EncryptionPassword.encryptionPassword;

  /// POST request with encrypted payload (raw text)
  Future<dynamic> post(Map<String, dynamic> body) async {
    print('Encryption password: $pwd');

    try {
      // Encrypt the request body
      print('Original body: $body');
      String encryptedBody = EncryptionUtils.encrypt(jsonEncode(body));
      print('Encrypted request: $encryptedBody');

      // Send the POST request as plain text
      print(baseUrl);
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'text/plain',
        },
        body: encryptedBody,
      );

      print('Status code: ${response.statusCode}');
      print('Encrypted response body: ${response.body}');

      if (response.statusCode == 200) {
        // The response should also be encrypted — decrypt it
        String decryptedResponse = EncryptionUtils.decrypt(response.body);
        print('Decrypted response: $decryptedResponse');
        return jsonDecode(decryptedResponse);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('API request failed');
    }
  }
}
