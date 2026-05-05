// v2.3 — Recovery Key offline (livello prodotto).
// 32 byte random → encoding base32 raggruppato (8 gruppi da 5 char).
// Memorizziamo SOLO l'hash della chiave (PBKDF2-SHA256, 100k iter)
// così la chiave plain è recuperabile solo se l'utente l'ha salvata.
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecoveryKeyService {
  RecoveryKeyService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _hashKey = 'aeterna_recovery_hash_v1';
  static const _saltKey = 'aeterna_recovery_salt_v1';

  static const String _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // base32 senza ambigui

  Future<bool> isSet() async {
    final h = await _storage.read(key: _hashKey);
    return h != null && h.isNotEmpty;
  }

  /// Genera una nuova recovery key, salva solo l'hash, ritorna la chiave
  /// in chiaro (mostrata UNA SOLA VOLTA all'utente per backup).
  Future<String> generateAndStore() async {
    final raw = _randomKey(40); // 40 char base32 = 200 bit entropia
    final formatted = _formatGroups(raw);

    final salt = _randomBytes(16);
    final hash = await _hash(_normalize(formatted), salt);

    await _storage.write(key: _saltKey, value: base64Encode(salt));
    await _storage.write(key: _hashKey, value: base64Encode(hash));

    return formatted;
  }

  /// Verifica una recovery key inserita dall'utente.
  Future<bool> verify(String input) async {
    final saltStr = await _storage.read(key: _saltKey);
    final hashStr = await _storage.read(key: _hashKey);
    if (saltStr == null || hashStr == null) return false;

    final salt = base64Decode(saltStr);
    final expected = base64Decode(hashStr);
    final actual = await _hash(_normalize(input), salt);

    return _constantTimeEquals(actual, expected);
  }

  Future<void> clear() async {
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _saltKey);
  }

  // ---------- helpers ----------

  String _normalize(String s) {
    return s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  String _formatGroups(String raw) {
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && i % 5 == 0) buf.write('-');
      buf.write(raw[i]);
    }
    return buf.toString();
  }

  String _randomKey(int len) {
    final r = Random.secure();
    final sb = StringBuffer();
    for (var i = 0; i < len; i++) {
      sb.write(_alphabet[r.nextInt(_alphabet.length)]);
    }
    return sb.toString();
  }

  List<int> _randomBytes(int n) {
    final r = Random.secure();
    return List<int>.generate(n, (_) => r.nextInt(256));
  }

  Future<List<int>> _hash(String value, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(value)),
      nonce: salt,
    );
    return await key.extractBytes();
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
