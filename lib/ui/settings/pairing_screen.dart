import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config.dart';
import '../../data/pairing_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key, this.initialCode});

  final String? initialCode;

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
    final l = AppLocalizations.of(context);
    final hasInitialCode = widget.initialCode != null;
    return DefaultTabController(
      length: 2,
      initialIndex: hasInitialCode ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.pairingTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.pairingShowCode),
              Tab(text: l.pairingEnterCode),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ShowCodeTab(service: _service),
            _EnterCodeTab(
              service: _service,
              initialCode: widget.initialCode,
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pairing = await widget.service.createCode();
      if (!mounted) return;
      setState(() {
        _code = pairing.code;
        _remaining = pairing.remainingSeconds;
      });
      _startCountdown();
    } catch (e) {
      if (mounted) setState(() => _error = l.pairingGenerateError);
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

  static String _qrPayload(String code) {
    const base = AppConfig.appUrl;
    if (base.isEmpty) return code;
    final uri = Uri.parse(base).replace(queryParameters: {'code': code});
    return uri.toString();
  }

  String get _countdownLabel {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l.pairingShowCodeInstructions,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_code != null) ...[
              QrImageView(
                data: _qrPayload(_code!),
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 16),
              SelectableText(
                _code!,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(l.pairingExpiresIn(_countdownLabel),
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
              label: Text(_code == null ? l.pairingGenerate : l.pairingGenerateNew),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnterCodeTab extends StatefulWidget {
  const _EnterCodeTab({required this.service, this.initialCode});

  final PairingService service;
  final String? initialCode;

  @override
  State<_EnterCodeTab> createState() => _EnterCodeTabState();
}

class _EnterCodeTabState extends State<_EnterCodeTab> {
  late final TextEditingController _controller;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final l = AppLocalizations.of(context);
    final code = PairingService.normalizeCode(_controller.text);
    if (code.isEmpty) return;
    final appScope = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final householdId = await widget.service.redeemCode(code);
      if (!mounted) return;
      appScope.onHouseholdChanged?.call(householdId);
      messenger.showSnackBar(
        SnackBar(content: Text(l.pairingSuccess)),
      );
      navigator.pop();
    } on PairingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = l.pairingError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l.pairingEnterCodeInstructions,
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
                : Text(l.pairingJoin),
          ),
        ],
      ),
    );
  }
}
