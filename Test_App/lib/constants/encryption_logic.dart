/*
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'dart:math';

class EncryptionUtils {
  static const int keySize = 256; // 256 bits
  static const int ivSize = 16;

  late final Key secretKey;
  late final IV ivParameterSpec;

  EncryptionUtils(String password) {
    this.secretKey = generateKey(password);
    this.ivParameterSpec = generateFixedIv(); // Use a fixed IV for testing
  }

  Key generateKey(String password) {
    final keyBytes =
        utf8.encode(password.padRight(keySize, '0').substring(0, keySize));
    print('Generated Key (Base64): ${base64.encode(keyBytes)}');
    return Key(Uint8List.fromList(keyBytes));
  }

  IV generateFixedIv() {
    final iv = Uint8List.fromList(
        List.generate(ivSize, (i) => 0)); // Example: All zeros
    print('Generated IV (Base64): ${base64.encode(iv)}');
    return IV(iv);
  }

  String encrypt(String plaintext) {
    final encrypter =
        Encrypter(AES(secretKey, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plaintext, iv: ivParameterSpec);
    print('Encrypted Bytes (Raw): ${encrypted.bytes}');
    return base64.encode(ivParameterSpec.bytes + encrypted.bytes);
  }

  String decrypt(String ciphertext) {
    final encryptedIvAndText = base64.decode(ciphertext);
    final iv = Uint8List.fromList(encryptedIvAndText.sublist(0, ivSize));
    final encryptedBytes =
        Uint8List.fromList(encryptedIvAndText.sublist(ivSize));
    final ivParameterSpec = IV(iv);
    final encrypter =
        Encrypter(AES(secretKey, mode: AESMode.cbc, padding: 'PKCS7'));
    final decrypted =
        encrypter.decrypt(Encrypted(encryptedBytes), iv: ivParameterSpec);
    return decrypted;
  }
}

void main() {
  const password = "App@#\$65";
  const plaintext =
      '{"serviceName":"Login ","pin":"2580","appId":"SID","mobNumber":"9164266003"}';

  final encryptionUtil = EncryptionUtils(password);

  // Encrypt
  final encrypted = encryptionUtil.encrypt(plaintext);
  print('Encrypted (Base64): $encrypted');

  // Decrypt (for validation)
  final decrypted = encryptionUtil.decrypt(encrypted);
  print('Decrypted: $decrypted');
}
*/
/*import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionUtils {
  static const int ivSize = 16;
  final encrypt.Key secretKey;

  EncryptionUtils(String password) : secretKey = _generateKey(password);

  static encrypt.Key _generateKey(String password) {
    final keyBytes = sha256.convert(utf8.encode(password)).bytes;
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  Uint8List _generateRandomIv() {
    final random = Random.secure();
    return Uint8List.fromList(
        List.generate(ivSize, (_) => random.nextInt(256)));
  }

  String encryptText(String plaintext) {
    final ivBytes = _generateRandomIv();
    final iv = encrypt.IV(ivBytes);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(secretKey, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    // Prepend IV like in Java
    final combined = iv.bytes + encrypted.bytes;
    return base64.encode(combined);
  }

  String decryptText(String base64Cipher) {
    final combined = base64.decode(base64Cipher);

    final ivBytes = combined.sublist(0, ivSize);
    final encryptedBytes = combined.sublist(ivSize);

    final decryptionIV = encrypt.IV(ivBytes);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(secretKey, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
    );

    final decrypted = encrypter.decrypt(
      encrypt.Encrypted(Uint8List.fromList(encryptedBytes)),
      iv: decryptionIV,
    );

    return decrypted;
  }
}*/
/*import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionUtils {
  static const int keySize = 32; // 256 bits
  static const int ivSize = 16;

  late Key secretKey;
  late IV iv;

  EncryptionUtils(String password) {
    final random = Random.secure();
    final seed = utf8.encode(password);
    final secureSeed = _expandSeed(seed, keySize);
    secretKey = Key(Uint8List.fromList(secureSeed));
    iv = IV.fromSecureRandom(ivSize);
  }

  Uint8List _expandSeed(List<int> seed, int length) {
    final rand = Random(seed.fold(0, (a, b) => a! + b));
    return Uint8List.fromList(List.generate(length, (_) => rand.nextInt(256)));
  }

  String encrypt(String plaintext) {
    final encrypter =
        Encrypter(AES(secretKey, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return base64.encode(iv.bytes + encrypted.bytes);
  }

  String decrypt(String base64Ciphertext) {
    final encrypted = base64.decode(base64Ciphertext);
    final ivBytes = encrypted.sublist(0, ivSize);
    final encryptedBytes = encrypted.sublist(ivSize);
    final encrypter =
        Encrypter(AES(secretKey, mode: AESMode.cbc, padding: 'PKCS7'));
    return encrypter.decrypt(Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: IV(ivBytes));
  }
}*/
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

class EncryptionUtils {
  static var random = Random.secure();
  static var iv = List<int>.generate(16, (_) => random.nextInt(256));
  static const encryptionKey = "TFRGUzAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc=";

  late Uint8List secretKey;

  static String encrypt(String data) {
    Uint8List keyBytes = base64.decode(encryptionKey);
    Uint8List iv = Uint8List.fromList(
      List<int>.generate(
        16,
        (_) => random.nextInt(16),
      ),
    );
    final cbcCipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(
        AESFastEngine(),
      ),
    );
    cbcCipher.init(
      true,
      PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(keyBytes), iv),
        null,
      ),
    );
    Uint8List unencryptedTextBytes = Uint8List.fromList(
      utf8.encode(data),
    );
    Uint8List encryptedTextBytes = cbcCipher.process(unencryptedTextBytes);

    Uint8List finalEncryption = Uint8List(
      iv.length + encryptedTextBytes.length,
    );

    finalEncryption.setRange(0, iv.length, iv);
    finalEncryption.setRange(
        iv.length, iv.length + encryptedTextBytes.length, encryptedTextBytes);

    return base64.encode(finalEncryption);
  }

  static String decrypt(String data) {
    Uint8List cipherText = base64.decode(data);
    Uint8List keyBytes = base64.decode(encryptionKey);
    Uint8List iv = Uint8List.fromList(copyOfRange(cipherText, 0, 16));
    Uint8List trimmedCipherText =
        Uint8List.fromList(copyOfRange(cipherText, 16, cipherText.length));

    final cbcCipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(
        AESFastEngine(),
      ),
    );
    cbcCipher.init(
      false,
      PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(keyBytes), iv),
        null,
      ),
    );
    Uint8List encryptedTextBytes = cbcCipher.process(trimmedCipherText);
    return utf8.decode(encryptedTextBytes);
  }

  static List<int> copyOfRange(List<int> cipherText, int from, int to) {
    return cipherText.sublist(from, to);
  }
}

void main() {
  final password = "App@#\$65";
  final fixedIv = "1234567890abcdef"; // 16-char IV just like Java SecureRandom

  final util = EncryptionUtils();

  final jsonText = '{"pinCode":"560078","serviceName":"getSchoolDetails"}';
  final encrypted = EncryptionUtils.encrypt(jsonText);
  print("Encrypted Base64: $encrypted");

  final decrypted = EncryptionUtils.decrypt(encrypted);
  print("Decrypted: $decrypted");
}
