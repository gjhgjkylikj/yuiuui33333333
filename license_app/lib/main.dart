import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(const LicenseApp());
}

Future<void> requestPermissions() async {
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
}

class LicenseApp extends StatelessWidget {
  const LicenseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const LicenseManager(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LicenseManager extends StatefulWidget {
  const LicenseManager({Key? key}) : super(key: key);

  @override
  State<LicenseManager> createState() => _LicenseManagerState();
}

class _LicenseManagerState extends State<LicenseManager> {
  late TextEditingController _licenseController;
  bool _isActivated = false;
  bool _isLoading = false;
  String _statusMessage = '';
  FocusNode _focusNodeInput = FocusNode();
  FocusNode _focusNodeActivate = FocusNode();
  FocusNode _focusNodeClear = FocusNode();
  late FocusNode _currentFocus;

  @override
  void initState() {
    super.initState();
    _licenseController = TextEditingController();
    _currentFocus = _focusNodeInput;
    _checkLicenseFile();
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _focusNodeInput.dispose();
    _focusNodeActivate.dispose();
    _focusNodeClear.dispose();
    super.dispose();
  }

  Future<void> _checkLicenseFile() async {
    try {
      final configDir = Directory('/storage/emulated/0/Android/.config');
      if (await configDir.exists()) {
        final licenseFile = File('${configDir.path}/license.json');
        if (await licenseFile.exists()) {
          final content = await licenseFile.readAsString();
          final data = jsonDecode(content);
          setState(() {
            _isActivated = true;
            _statusMessage = 'Licença carregada: ${data['license'] ?? 'Ativa'}';
          });
        }
      }
    } catch (e) {
      print('Erro ao verificar arquivo: $e');
    }
  }

  Future<void> _saveLicenseFile(String license) async {
    try {
      final configDir = Directory('/storage/emulated/0/Android/.config');
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      
      final licenseFile = File('${configDir.path}/license.json');
      final data = {
        'license': license,
        'activated_at': DateTime.now().toIso8601String(),
      };
      
      await licenseFile.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Erro ao salvar arquivo: $e');
      rethrow;
    }
  }

  Future<void> _deleteLicenseFile() async {
    try {
      final configDir = Directory('/storage/emulated/0/Android/.config');
      if (await configDir.exists()) {
        final licenseFile = File('${configDir.path}/license.json');
        if (await licenseFile.exists()) {
          await licenseFile.delete();
        }
      }
      
      setState(() {
        _isActivated = false;
        _licenseController.clear();
        _statusMessage = 'Licença removida. Digite uma nova chave.';
        _currentFocus = _focusNodeInput;
        _focusNodeInput.requestFocus();
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao remover licença: $e';
      });
    }
  }

  Future<void> _activateLicense() async {
    if (_licenseController.text.isEmpty) {
      setState(() {
        _statusMessage = 'Por favor, digite uma chave de licença.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Ativando licença...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://fluffernutter-joy-factory.lovable.app/endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'license_key': _licenseController.text,
          'device_id': 'android_tv_device',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveLicenseFile(_licenseController.text);
        setState(() {
          _isActivated = true;
          _statusMessage = 'Licença ativada com sucesso!';
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = 'Erro na ativação: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        _statusMessage = 'Erro de conexão. Verifique a rede.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro: $e';
        _isLoading = false;
      });
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final isArrowDown = event.logicalKey == LogicalKeyboardKey.arrowDown;
      final isArrowUp = event.logicalKey == LogicalKeyboardKey.arrowUp;
      final isArrowLeft = event.logicalKey == LogicalKeyboardKey.arrowLeft;
      final isArrowRight = event.logicalKey == LogicalKeyboardKey.arrowRight;
      final isEnter = event.logicalKey == LogicalKeyboardKey.enter;

      if (isArrowDown || isArrowRight) {
        if (_currentFocus == _focusNodeInput) {
          _currentFocus = _focusNodeActivate;
          _focusNodeActivate.requestFocus();
        } else if (_currentFocus == _focusNodeActivate) {
          if (_isActivated) {
            _currentFocus = _focusNodeClear;
            _focusNodeClear.requestFocus();
          } else {
            _currentFocus = _focusNodeInput;
            _focusNodeInput.requestFocus();
          }
        } else if (_currentFocus == _focusNodeClear) {
          _currentFocus = _focusNodeInput;
          _focusNodeInput.requestFocus();
        }
      } else if (isArrowUp || isArrowLeft) {
        if (_currentFocus == _focusNodeActivate) {
          _currentFocus = _focusNodeInput;
          _focusNodeInput.requestFocus();
        } else if (_currentFocus == _focusNodeClear) {
          _currentFocus = _focusNodeActivate;
          _focusNodeActivate.requestFocus();
        } else if (_currentFocus == _focusNodeInput) {
          if (_isActivated) {
            _currentFocus = _focusNodeClear;
            _focusNodeClear.requestFocus();
          } else {
            _currentFocus = _focusNodeActivate;
            _focusNodeActivate.requestFocus();
          }
        }
      } else if (isEnter) {
        if (_currentFocus == _focusNodeActivate) {
          _activateLicense();
        } else if (_currentFocus == _focusNodeClear) {
          _deleteLicenseFile();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: _isActivated ? _buildDashboard() : _buildActivationScreen(),
        ),
      ),
    );
  }

  Widget _buildActivationScreen() {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Ativação de Licença',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Focus(
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                _activateLicense();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              focusNode: _focusNodeInput,
              controller: _licenseController,
              enabled: !_isLoading,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Digite sua chave de licença',
                hintStyle: TextStyle(fontSize: 20, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.cyan, width: 3),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Focus(
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                _activateLicense();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Container(
              decoration: BoxDecoration(
                border: _focusNodeActivate.hasFocus
                    ? Border.all(color: Colors.cyan, width: 3)
                    : Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                focusNode: _focusNodeActivate,
                onPressed: _isLoading ? null : _activateLicense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _focusNodeActivate.hasFocus
                      ? Colors.cyan
                      : Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Ativar',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            _statusMessage,
            style: TextStyle(
              fontSize: 20,
              color: _statusMessage.contains('sucesso')
                  ? Colors.green
                  : _statusMessage.contains('Erro')
                      ? Colors.red
                      : Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Painel de Controle',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  '✓ Sistema Ativado',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Focus(
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                _deleteLicenseFile();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Container(
              decoration: BoxDecoration(
                border: _focusNodeClear.hasFocus
                    ? Border.all(color: Colors.orangeAccent, width: 3)
                    : Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                focusNode: _focusNodeClear,
                onPressed: _deleteLicenseFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _focusNodeClear.hasFocus
                      ? Colors.orangeAccent
                      : Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Remover Licença',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
