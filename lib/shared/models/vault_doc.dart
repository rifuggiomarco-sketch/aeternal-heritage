// Bug #7 fix: aggiunto copyWith, == e hashCode per immutabilità garantita.
import 'package:uuid/uuid.dart';

enum DocCategory { identity, financial, legal, personal, medical, other }

extension DocCategoryLabel on DocCategory {
  String get label {
    switch (this) {
      case DocCategory.identity:
        return 'Identità';
      case DocCategory.financial:
        return 'Finanza';
      case DocCategory.legal:
        return 'Legale';
      case DocCategory.personal:
        return 'Personale';
      case DocCategory.medical:
        return 'Medico';
      case DocCategory.other:
        return 'Altro';
    }
  }
}

class VaultDoc {
  final String id;
  final String name;
  final String extension;
  final int sizeBytes;
  final DocCategory category;
  final DateTime uploadedAt;
  final DateTime? updatedAt;
  final String ciphertextUrl;
  final String encryptedMeta;
  final String heirAccessLevel;
  final bool isSharedWithHeirs;

  VaultDoc({
    String? id,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    this.category = DocCategory.other,
    DateTime? uploadedAt,
    this.updatedAt,
    required this.ciphertextUrl,
    this.encryptedMeta = '',
    this.heirAccessLevel = 'read',
    this.isSharedWithHeirs = false,
  })  : id = id ?? const Uuid().v4(),
        uploadedAt = uploadedAt ?? DateTime.now();

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ─── Immutabilità ────────────────────────────────────────────────────────────

  VaultDoc copyWith({
    String? id,
    String? name,
    String? extension,
    int? sizeBytes,
    DocCategory? category,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    String? ciphertextUrl,
    String? encryptedMeta,
    String? heirAccessLevel,
    bool? isSharedWithHeirs,
  }) =>
      VaultDoc(
        id: id ?? this.id,
        name: name ?? this.name,
        extension: extension ?? this.extension,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        category: category ?? this.category,
        uploadedAt: uploadedAt ?? this.uploadedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        ciphertextUrl: ciphertextUrl ?? this.ciphertextUrl,
        encryptedMeta: encryptedMeta ?? this.encryptedMeta,
        heirAccessLevel: heirAccessLevel ?? this.heirAccessLevel,
        isSharedWithHeirs: isSharedWithHeirs ?? this.isSharedWithHeirs,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultDoc &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          extension == other.extension &&
          sizeBytes == other.sizeBytes &&
          category == other.category &&
          uploadedAt == other.uploadedAt &&
          ciphertextUrl == other.ciphertextUrl &&
          isSharedWithHeirs == other.isSharedWithHeirs;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        extension,
        sizeBytes,
        category,
        uploadedAt,
        ciphertextUrl,
        isSharedWithHeirs,
      );

  // ─── Serializzazione ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'extension': extension,
        'sizeBytes': sizeBytes,
        'category': category.name,
        'uploadedAt': uploadedAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'ciphertextUrl': ciphertextUrl,
        'encryptedMeta': encryptedMeta,
        'heirAccessLevel': heirAccessLevel,
        'isSharedWithHeirs': isSharedWithHeirs,
      };

  factory VaultDoc.fromJson(Map<String, dynamic> json) => VaultDoc(
        id: json['id'] as String,
        name: json['name'] as String,
        extension: json['extension'] as String,
        sizeBytes: json['sizeBytes'] as int,
        category: DocCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => DocCategory.other,
        ),
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        ciphertextUrl: json['ciphertextUrl'] as String,
        encryptedMeta: json['encryptedMeta'] as String? ?? '',
        heirAccessLevel: json['heirAccessLevel'] as String? ?? 'read',
        isSharedWithHeirs: json['isSharedWithHeirs'] as bool? ?? false,
      );
}
