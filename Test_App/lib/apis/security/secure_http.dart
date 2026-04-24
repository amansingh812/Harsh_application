import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../config/env.dart';

class SecureHttp {
  static Dio create() {
    final dio = Dio();

    if (!Env.enableSslPinning) {
      // 🔓 LOCAL / STAGING
      return dio;
    }

    // 🔐 PRODUCTION ONLY
    dio.httpClientAdapter = IOHttpClientAdapter()
      ..createHttpClient = () {
        final client = HttpClient();

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          final certDer = cert.der;
          final hash = sha256.convert(certDer).bytes;
          final serverPin = base64Encode(hash);

          const pinned =
              "nTXfiWNvwONSkknguvph97vdiWEySQUFf3N1GaYwNAU=";

          return serverPin == pinned;
        };

        return client;
      };

    return dio;
  }
}
