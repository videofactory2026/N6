import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class EncryptedStorageService {
  static final EncryptedStorageService _instance = EncryptedStorageService._internal();
  factory EncryptedStorageService() => _instance;
  EncryptedStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  late encrypt_lib.Encrypter _encrypter;
  late encrypt_lib.IV _iv;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Get or create encryption key
    String? keyString = await _secureStorage.read(key: 'encryption_key');
    
    if (keyString == null) {
      // Generate new key
      final key = encrypt_lib.Key.fromSecureRandom(32);
      keyString = base64.encode(key.bytes);
      await _secureStorage.write(key: 'encryption_key', value: keyString);
    }

    final key = encrypt_lib.Key(base64.decode(keyString));
    _iv = encrypt_lib.IV.fromSecureRandom(16);
    _encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
    _initialized = true;
  }

  Future<void> saveEncrypted(String key, Map<String, dynamic> data) async {
    await initialize();
    final jsonString = json.encode(data);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    await _secureStorage.write(key: key, value: encrypted.base64);
  }

  Future<Map<String, dynamic>?> readEncrypted(String key) async {
    await initialize();
    final encryptedString = await _secureStorage.read(key: key);
    
    if (encryptedString == null) return null;

    try {
      final encrypted = encrypt_lib.Encrypted.fromBase64(encryptedString);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return json.decode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      print('Decryption error: $e');
      return null;
    }
  }

  Future<void> deleteEncrypted(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAllData() async {
    await _secureStorage.deleteAll();
    _initialized = false;
  }

  String hashData(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }
}
