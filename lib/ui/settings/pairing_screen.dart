import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/pairing_service.dart';
import '../app_scope.dart';

/// Pairing of a second device (ADR-006). Two ways: "Mostra codice" on the
/// inviting phone and "Inserisci codice" on the one that joins.
class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  late final PairingService _service;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = PairingService(Supabase.instance.client);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Abbina un dispositivo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mostra codice'),
              Tab(text: 'Inserisci codice'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ShowCodeTab(service: _service),
            _EnterCodeTab(service: _service),
          ],
        ),
      ),
    );
  }
}

/// Inviting phone: generates and shows a code with a validity countdown.
class _ShowCodeTab extends StatefulWidget {
  const _ShowCodeTab({required this.service});

  final PairingService service;

  @override
  State<_ShowCodeTab> createState() => _ShowCodeTabState();
}

class _ShowCodeTabState extends State<_ShowCodeTab> {
  String? _code;
  bool _loading = false;
  String? _error;
  Timer? _timer;
  int _remaining = 0;

  static const _validitySeconds = 600; // consistent with the SQL function

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final code = await widget.service.createCode();
      if (!mounted) return;
      setState(() {
        _code = code;
        _remaining = _validitySeconds;
      });
      _startCountdown();
    } catch (e) {
      if (mounted) setState(() => _error = 'Impossibile generare il codice.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        setState(() => _code = null);
      }
    });
  }

  String get _countdownLabel {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Genera un codice e digitalo sull\'altro telefono entro la scadenza.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_code != null) ...[
            SelectableText(
              _code!,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Scade tra $_countdownLabel',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
          ],
          if (_error != null) ...[
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: _loading ? null : _generate,
            icon: const Icon(Icons.qr_code),
            label: Text(_code == null ? 'Genera codice' : 'Genera nuovo codice'),
          ),
        ],
      ),
    );
  }
}

/// Joining phone: enters the code and adopts the household of whoever
/// generated it.
class _EnterCodeTab extends StatefulWidget {
  const _EnterCodeTab({required this.service});

  final PairingService service;

  @override
  State<_EnterCodeTab> createState() => _EnterCodeTabState();
}

class _EnterCodeTabState extends State<_EnterCodeTab> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = PairingService.normalizeCode(_controller.text);
    if (code.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final householdId = await widget.service.redeemCode(code);
      if (!mounted) return;
      // Switch to the just-adopted household: the tree rebuilds with the
      // right repositories; PowerSync will sync the data in the background.
      AppScope.of(context).onHouseholdChanged?.call(householdId);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispositivo abbinato. Sincronizzazione in corso…'),
        ),
      );
    } on PairingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Abbinamento non riuscito.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Inserisci il codice mostrato sull\'altro telefono.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 8,
                ),
            decoration: const InputDecoration(
              counterText: '',
              hintText: '••••••',
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _loading ? null : _redeem,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Unisciti'),
          ),
        ],
      ),
    );
  }
}
