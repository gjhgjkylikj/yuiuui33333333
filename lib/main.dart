import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

const String kLicenseEndpoint =
    'https://fluffernutter-joy-factory.lovable.app/endpoint';

const String kConfigDirPath =
    '/storage/emulated/0/Android/data/com.example.license_app/files';

const String kConfigFileName = 'config.json';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LicenseApp());
}

class LicenseApp extends StatelessWidget {
  const LicenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        focusColor: Colors.blueAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const StartupGate(),
    );
  }
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _loading = true;
  bool _hasConfig = false;
  Map<String, dynamic>? _configData;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _requestPermissions();
    await _checkExistingConfig();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _checkExistingConfig() async {
    try {
      final file = File('$kConfigDirPath/$kConfigFileName');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        setState(() {
          _hasConfig = true;
          _configData = data;
          _loading = false;
        });
        return;
      }
    } catch (_) {
      // Se houver falha de leitura/parse, cai para tela de ativação
    }
    setState(() {
      _hasConfig = false;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hasConfig && _configData != null) {
      return DashboardScreen(configData: _configData!);
    }
    return const ActivationScreen();
  }
}

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _keyController = TextEditingController();
  final FocusNode _fieldFocusNode = FocusNode();
  final FocusNode _buttonFocusNode = FocusNode();

  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_fieldFocusNode);
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    _fieldFocusNode.dispose();
    _buttonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _errorMessage = 'Digite uma chave de licença válida.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(kLicenseEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'license_key': key}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          responseData = <String, dynamic>{};
        }

        final configToSave = <String, dynamic>{
          'license_key': key,
          'activated_at': DateTime.now().toIso8601String(),
          'server_response': responseData,
        };

        await _saveConfig(configToSave);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(configData: configToSave),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Falha na ativação (HTTP ${response.statusCode}). Verifique a chave.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _saveConfig(Map<String, dynamic> data) async {
    final dir = Directory(kConfigDirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('$kConfigDirPath/$kConfigFileName');
    await file.writeAsString(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.vpn_key, size: 72, color: Colors.blueAccent),
                const SizedBox(height: 24),
                const Text(
                  'Ativação de Licença',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Digite sua chave de licença para continuar',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TvFocusable(
                  focusNode: _fieldFocusNode,
                  onSelect: () {
                    FocusScope.of(context).requestFocus(_fieldFocusNode);
                  },
                  builder: (context, hasFocus) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasFocus ? Colors.blueAccent : Colors.white24,
                          width: hasFocus ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _keyController,
                        focusNode: _fieldFocusNode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, letterSpacing: 2),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          hintText: 'CHAVE-DE-LICENCA',
                        ),
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_buttonFocusNode);
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                TvFocusable(
                  focusNode: _buttonFocusNode,
                  onSelect: _submitting ? null : _activate,
                  builder: (context, hasFocus) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: hasFocus ? Colors.blueAccent : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: hasFocus ? Colors.white : Colors.white24,
                          width: hasFocus ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: _submitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'ATIVAR',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> configData;

  const DashboardScreen({super.key, required this.configData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FocusNode _deleteButtonFocusNode = FocusNode();
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_deleteButtonFocusNode);
    });
  }

  @override
  void dispose() {
    _deleteButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _deleteConfig() async {
    setState(() {
      _deleting = true;
    });
    try {
      final file = File('$kConfigDirPath/$kConfigFileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Segue o fluxo mesmo se a exclusão falhar parcialmente
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ActivationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final licenseKey = widget.configData['license_key']?.toString() ?? '-';
    final activatedAt = widget.configData['activated_at']?.toString() ?? '-';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Painel',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Licença ativa neste dispositivo',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chave: $licenseKey',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Ativado em: $activatedAt',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 280,
              child: TvFocusable(
                focusNode: _deleteButtonFocusNode,
                onSelect: _deleting ? null : _deleteConfig,
                builder: (context, hasFocus) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: hasFocus ? Colors.redAccent : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasFocus ? Colors.white : Colors.white24,
                        width: hasFocus ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: _deleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'APAGAR CONFIG',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef TvFocusBuilder = Widget Function(BuildContext context, bool hasFocus);

class TvFocusable extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback? onSelect;
  final TvFocusBuilder builder;

  const TvFocusable({
    super.key,
    required this.focusNode,
    required this.onSelect,
    required this.builder,
  });

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = widget.focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          widget.onSelect?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onSelect,
        child: widget.builder(context, _hasFocus),
      ),
    );
  }
}
