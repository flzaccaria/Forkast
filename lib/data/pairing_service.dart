import 'package:supabase_flutter/supabase_flutter.dart';

/// Device pairing (ADR-006). Wraps the calls to the Postgres
/// `SECURITY DEFINER` functions (see 00002_pairing.sql), the only ones allowed
/// to write a membership into a household the device is not yet part of.
/// Requires network: it is a one-time setup, not an offline-first operation.
class PairingService {
  PairingService(this._client);

  final SupabaseClient _client;

  /// Inviting device: generates a 6-digit code. The server returns the code
  /// and its expiry so the client can count down without hardcoding the
  /// validity duration.
  Future<PairingCode> createCode() async {
    final res = await _client.rpc('create_pairing_code');
    final map = res as Map<String, dynamic>;
    return PairingCode(
      code: map['code'] as String,
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }

  /// Second device: redeems the code and joins the inviter's household.
  /// Returns the adopted `household_id`. Throws [PairingException] with a
  /// readable reason on error.
  Future<String> redeemCode(String code) async {
    try {
      final res = await _client.rpc(
        'redeem_pairing_code',
        params: {'p_code': normalizeCode(code)},
      );
      return res as String;
    } on PostgrestException catch (e) {
      throw PairingException.fromPostgrest(e);
    }
  }

  // Email seam (future phase, ADR-006): when the anonymous identity is
  // promoted to a real account, the email invite will reuse the same
  // server-side membership-adding mechanism (a twin function of
  // redeem_pairing_code that resolves the device from the email instead of the code).
  // Not implemented in this phase to avoid introducing PII (ADR-008).
  // Future<void> inviteByEmail(String email) { ... }

  /// Normalizes the user's input: removes spaces and dashes.
  static String normalizeCode(String raw) =>
      raw.replaceAll(RegExp(r'[\s-]'), '').trim();
}

/// Code + server-provided expiry returned by [PairingService.createCode].
class PairingCode {
  PairingCode({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;

  int get remainingSeconds =>
      expiresAt.difference(DateTime.now().toUtc()).inSeconds.clamp(0, 86400);
}

/// Pairing error with a message already localized for the UI.
class PairingException implements Exception {
  PairingException(this.message);

  final String message;

  factory PairingException.fromPostgrest(PostgrestException e) {
    final reason = e.message;
    if (reason.contains('invalid_or_expired_code')) {
      return PairingException('Codice non valido o scaduto.');
    }
    if (reason.contains('device_has_data')) {
      return PairingException(
          'Questo dispositivo ha già dati propri: l\'abbinamento li '
          'scarterebbe. Usa un dispositivo senza dati per unirti.');
    }
    if (reason.contains('no_household')) {
      return PairingException('Nessun household su questo dispositivo.');
    }
    if (reason.contains('not_authenticated')) {
      return PairingException('Sessione non valida. Riprova.');
    }
    return PairingException('Abbinamento non riuscito. Riprova.');
  }

  @override
  String toString() => message;
}
