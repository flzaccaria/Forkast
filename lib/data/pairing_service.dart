import 'package:supabase_flutter/supabase_flutter.dart';

/// Abbinamento dei dispositivi (ADR-006). Incapsula le chiamate alle funzioni
/// Postgres `SECURITY DEFINER` (vedi 00002_pairing.sql), le uniche autorizzate
/// a scrivere una membership in un household di cui il dispositivo non fa
/// ancora parte. Richiede rete: è una configurazione una-tantum, non una
/// operazione offline-first.
class PairingService {
  PairingService(this._client);

  final SupabaseClient _client;

  /// Dispositivo che invita: genera un codice a 6 cifre, valido ~10 minuti.
  Future<String> createCode() async {
    final res = await _client.rpc('create_pairing_code');
    return res as String;
  }

  /// Secondo dispositivo: consuma il codice ed entra nell'household di chi ha
  /// invitato. Ritorna l'`household_id` adottato. Lancia [PairingException]
  /// con un motivo leggibile in caso di errore.
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

  // Predisposizione email (fase futura, ADR-006): quando l'identità anonima
  // sarà promossa ad account reale, l'invito via email riuserà lo stesso
  // meccanismo server-side di aggiunta membership (una funzione gemella di
  // redeem_pairing_code che risolve il device dall'email invece che dal codice).
  // Non implementato in questa fase per non introdurre PII (ADR-008).
  // Future<void> inviteByEmail(String email) { ... }

  /// Normalizza l'input dell'utente: rimuove spazi e trattini.
  static String normalizeCode(String raw) =>
      raw.replaceAll(RegExp(r'[\s-]'), '').trim();
}

/// Errore di abbinamento con messaggio già localizzato per la UI.
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
