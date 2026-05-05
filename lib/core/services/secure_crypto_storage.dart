// v2.3 — Salt random unico per dispositivo (fix bug critico salt hardcoded).
// Sostituisce il salt costante 'aeterna_salt' con un salt sicuro generato a
// runtime e persistito in FlutterSecureStorage (Keystore/Keychain).
import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCryptoStorage {
  SecureCryptoStorage();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _saltKey = 'aeterna_crypto_salt_v1';

  /// Restituisce il salt esistente o ne genera uno nuovo (16 byte random).
  /// Persistito in secure storage cifrato dal sistema.
  Future<List<int>> getOrCreateSalt() async {
    final existing = await _storage.read(key: _saltKey);
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }

    final salt = _generateSalt();
    await _storage.write(
      key: _saltKey,
      value: base64Encode(salt),
    );
    return salt;
  }

  /// Reset salt (usato in caso di logout completo / reset vault).
  Future<void> resetSalt() async {
    await _storage.delete(key: _saltKey);
  }

  List<int> _generateSalt() {
    final rand = Random.secure();
    return List<int>.generate(16, (_) => rand.nextInt(256));
  }
}
