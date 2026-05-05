// v2.4 — Shamir Secret Sharing su GF(256).
// Permette di splittare un segreto (es. una chiave AES) in N parti di cui
// solo K sono necessarie a ricostruirlo. Implementazione canonica
// (https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing).
import 'dart:math';
import 'dart:typed_data';

class ShamirShare {
  final int x; // 1..255
  final Uint8List y;
  ShamirShare(this.x, this.y);

  String toBase64() {
    final out = Uint8List(1 + y.length);
    out[0] = x;
    out.setRange(1, out.length, y);
    // Base64 url-safe
    return _b64(out);
  }

  static ShamirShare fromBase64(String s) {
    final bytes = _b64Decode(s);
    if (bytes.isEmpty) throw FormatException('share vuota');
    return ShamirShare(bytes[0], Uint8List.fromList(bytes.sublist(1)));
  }
}

class ShamirService {
  /// Splitta `secret` in `n` shares; servono `k` shares per ricostruire.
  List<ShamirShare> split({
    required Uint8List secret,
    required int n,
    required int k,
  }) {
    if (k < 2 || k > n || n > 255) {
      throw ArgumentError('Parametri non validi: 2 <= k <= n <= 255');
    }

    final rnd = Random.secure();
    final shares = List.generate(
      n,
      (_) => Uint8List(secret.length),
    );

    for (var b = 0; b < secret.length; b++) {
      // polinomio di grado k-1: a0 = secret[b]; a1..a_{k-1} random
      final coeffs = List<int>.generate(
        k,
        (i) => i == 0 ? secret[b] : rnd.nextInt(256),
      );
      for (var i = 0; i < n; i++) {
        final x = i + 1; // x ∈ [1, n]
        shares[i][b] = _evalPoly(coeffs, x);
      }
    }

    return List.generate(n, (i) => ShamirShare(i + 1, shares[i]));
  }

  /// Ricostruisce il segreto da almeno `k` shares (Lagrange in GF(256)).
  Uint8List combine(List<ShamirShare> shares) {
    if (shares.length < 2) {
      throw ArgumentError('Servono almeno 2 shares');
    }
    final len = shares.first.y.length;
    if (shares.any((s) => s.y.length != len)) {
      throw ArgumentError('Shares di lunghezza diversa');
    }
    final out = Uint8List(len);
    for (var b = 0; b < len; b++) {
      var secret = 0;
      for (var i = 0; i < shares.length; i++) {
        var num = 1;
        var den = 1;
        for (var j = 0; j < shares.length; j++) {
          if (i == j) continue;
          num = _gfMul(num, shares[j].x);
          den = _gfMul(den, shares[i].x ^ shares[j].x);
        }
        final lagrange = _gfMul(num, _gfInverse(den));
        secret ^= _gfMul(shares[i].y[b], lagrange);
      }
      out[b] = secret;
    }
    return out;
  }

  int _evalPoly(List<int> coeffs, int x) {
    var acc = 0;
    for (var i = coeffs.length - 1; i >= 0; i--) {
      acc = _gfMul(acc, x) ^ coeffs[i];
    }
    return acc;
  }

  // ---- GF(256) AES poly 0x11b ----
  static final List<int> _exp = _buildExp();
  static final List<int> _log = _buildLog();

  static List<int> _buildExp() {
    final exp = List<int>.filled(512, 0);
    var v = 1;
    for (var i = 0; i < 255; i++) {
      exp[i] = v;
      final hi = v & 0x80;
      v = (v << 1) & 0xff;
      if (hi != 0) v ^= 0x1b;
    }
    for (var i = 255; i < 512; i++) {
      exp[i] = exp[i - 255];
    }
    return exp;
  }

  static List<int> _buildLog() {
    final log = List<int>.filled(256, 0);
    for (var i = 0; i < 255; i++) {
      log[_exp[i]] = i;
    }
    return log;
  }

  int _gfMul(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return _exp[(_log[a] + _log[b]) % 255];
  }

  int _gfInverse(int a) {
    if (a == 0) throw ArgumentError('inverse(0)');
    return _exp[(255 - _log[a]) % 255];
  }
}

// --- helpers base64 url-safe ---
String _b64(Uint8List b) {
  const alpha =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  final sb = StringBuffer();
  for (var i = 0; i < b.length; i += 3) {
    final n = (b[i] << 16) |
        ((i + 1 < b.length ? b[i + 1] : 0) << 8) |
        (i + 2 < b.length ? b[i + 2] : 0);
    sb.write(alpha[(n >> 18) & 63]);
    sb.write(alpha[(n >> 12) & 63]);
    if (i + 1 < b.length) sb.write(alpha[(n >> 6) & 63]);
    if (i + 2 < b.length) sb.write(alpha[n & 63]);
  }
  return sb.toString();
}

Uint8List _b64Decode(String s) {
  const alpha =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  final lookup = <int, int>{};
  for (var i = 0; i < alpha.length; i++) {
    lookup[alpha.codeUnitAt(i)] = i;
  }
  final clean = s.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '');
  final out = <int>[];
  for (var i = 0; i < clean.length; i += 4) {
    final c0 = lookup[clean.codeUnitAt(i)] ?? 0;
    final c1 = (i + 1 < clean.length) ? lookup[clean.codeUnitAt(i + 1)] ?? 0 : 0;
    final c2 = (i + 2 < clean.length) ? lookup[clean.codeUnitAt(i + 2)] ?? 0 : 0;
    final c3 = (i + 3 < clean.length) ? lookup[clean.codeUnitAt(i + 3)] ?? 0 : 0;
    final n = (c0 << 18) | (c1 << 12) | (c2 << 6) | c3;
    out.add((n >> 16) & 0xff);
    if (i + 2 < clean.length) out.add((n >> 8) & 0xff);
    if (i + 3 < clean.length) out.add(n & 0xff);
  }
  return Uint8List.fromList(out);
}
