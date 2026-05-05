// v2.3 — Usa SecureCryptoStorage per ottenere il salt sicuro.
import 'package:aeterna_protocol/core/services/encryption_service.dart';
import 'package:aeterna_protocol/core/services/secure_crypto_storage.dart';
import 'package:aeterna_protocol/core/services/secure_key_service.dart';

class VaultRepository {
  final EncryptionService encryptionService;
  final SecureKeyService keyService;
  final SecureCryptoStorage cryptoStorage;

  VaultRepository({
    required this.encryptionService,
    required this.keyService,
    required this.cryptoStorage,
  });

  Future<Map<String, String>> encryptData(String data) async {
    final masterKey = await keyService.getOrCreateKey();
    final salt = await cryptoStorage.getOrCreateSalt();
    final key = await encryptionService.deriveKey(masterKey, salt);

    return await encryptionService.encrypt(
      data: data,
      key: key,
    );
  }

  Future<String> decryptData(Map<String, String> payload) async {
    final masterKey = await keyService.getOrCreateKey();
    final salt = await cryptoStorage.getOrCreateSalt();
    final key = await encryptionService.deriveKey(masterKey, salt);

    return await encryptionService.decrypt(
      payload: payload,
      key: key,
    );
  }
}
