import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final storage = FlutterSecureStorage();

  static void save(dynamic key, dynamic value) async {
    await storage.write(key: key.toString(), value: value.toString());
  }

  static Future<String?> read(dynamic key) async {
    return await storage.read(key: key.toString());
  }

  static Future<void> delete(dynamic key) async {
    await storage.delete(key: key.toString());
  }
}
