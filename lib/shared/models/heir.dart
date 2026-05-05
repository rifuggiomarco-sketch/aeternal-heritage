// Bug #7 fix: aggiunto copyWith, == e hashCode per immutabilità garantita
// senza dipendenze esterne (freezed/equatable non necessari per la v2.1).
import 'package:uuid/uuid.dart';

enum HeirRelationship { spouse, child, parent, sibling, friend, lawyer, other }

extension HeirRelationshipLabel on HeirRelationship {
  String get label {
    switch (this) {
      case HeirRelationship.spouse:
        return 'Coniuge / Partner';
      case HeirRelationship.child:
        return 'Figlio / Figlia';
      case HeirRelationship.parent:
        return 'Genitore';
      case HeirRelationship.sibling:
        return 'Fratello / Sorella';
      case HeirRelationship.friend:
        return 'Amico / Amica';
      case HeirRelationship.lawyer:
        return 'Avvocato / Notaio';
      case HeirRelationship.other:
        return 'Altro';
    }
  }
}

class Heir {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final HeirRelationship relationship;
  final bool canViewAll;
  final List<String> allowedDocIds;
  final bool isVerified;
  final DateTime addedAt;

  Heir({
    String? id,
    required this.fullName,
    required this.email,
    this.phone,
    this.relationship = HeirRelationship.other,
    this.canViewAll = false,
    this.allowedDocIds = const [],
    this.isVerified = false,
    DateTime? addedAt,
  })  : id = id ?? const Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  // ─── Immutabilità ────────────────────────────────────────────────────────────

  Heir copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    HeirRelationship? relationship,
    bool? canViewAll,
    List<String>? allowedDocIds,
    bool? isVerified,
    DateTime? addedAt,
  }) =>
      Heir(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        relationship: relationship ?? this.relationship,
        canViewAll: canViewAll ?? this.canViewAll,
        allowedDocIds: allowedDocIds ?? this.allowedDocIds,
        isVerified: isVerified ?? this.isVerified,
        addedAt: addedAt ?? this.addedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Heir &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          email == other.email &&
          phone == other.phone &&
          relationship == other.relationship &&
          canViewAll == other.canViewAll &&
          isVerified == other.isVerified &&
          addedAt == other.addedAt;

  @override
  int get hashCode => Object.hash(
        id,
        fullName,
        email,
        phone,
        relationship,
        canViewAll,
        isVerified,
        addedAt,
      );

  // ─── Serializzazione ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'relationship': relationship.name,
        'canViewAll': canViewAll,
        'allowedDocIds': allowedDocIds,
        'isVerified': isVerified,
        'addedAt': addedAt.toIso8601String(),
      };

  factory Heir.fromJson(Map<String, dynamic> json) => Heir(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        relationship: HeirRelationship.values.firstWhere(
          (r) => r.name == json['relationship'],
          orElse: () => HeirRelationship.other,
        ),
        canViewAll: json['canViewAll'] as bool? ?? false,
        allowedDocIds:
            List<String>.from(json['allowedDocIds'] as List? ?? []),
        isVerified: json['isVerified'] as bool? ?? false,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
