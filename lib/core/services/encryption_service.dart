// v2.3 — deriveKey accetta un salt esterno (sicuro, generato per device)
// invece di un salt hardcoded. AES-256-GCM rimane invariato.
import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class EncryptionService {
  final AesGcm _algorithm = AesGcm.with256bits();

  /// Deriva una chiave AES-256 da una master key + salt.
  /// Il salt DEVE essere fornito (random e persistito in SecureCryptoStorage).
  Future<SecretKey> deriveKey(String masterKey, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );

    return await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(masterKey)),
      nonce: salt,
    );
  }

  Future<Map<String, String>> encrypt({
    required String data,
    required SecretKey key,
  }) async {
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      utf8.encode(data),
      secretKey: key,
      nonce: nonce,
    );

    return {
      'cipher': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  Future<String> decrypt({
    required Map<String, String> payload,
    required SecretKey key,
  }) async {
    final secretBox = SecretBox(
      base64Decode(payload['cipher']!),
      nonce: base64Decode(payload['nonce']!),
      mac: Mac(base64Decode(payload['mac']!)),
    );

    final clear = await _algorithm.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(clear);
  }
}
