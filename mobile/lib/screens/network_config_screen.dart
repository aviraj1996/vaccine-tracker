// Network Configuration Screen
// Allows users to configure the web app API URL for local testing

import 'package:flutter/material.dart';
import '../services/network_config_service.dart';
import '../utils/network_utils.dart';

class NetworkConfigScreen extends StatefulWidget {
  const NetworkConfigScreen({super.key});

  @override
  State<NetworkConfigScreen> createState() => _NetworkConfigScreenState();
}

class _NetworkConfigScreenState extends State<NetworkConfigScreen> {
  final NetworkConfigService _configService = NetworkConfigService();
  final TextEditingController _urlController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _detectedIP;
  String? _currentUrl;
  List<String> _suggestedUrls = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current URL
      final currentUrl = await _configService.getWebAppUrl();

      // Detect local IP
      final detectedIP = await NetworkUtils.getLocalIPAddress();

      // Get suggested URLs
      final suggestions = await _configService.getSuggestedUrls();

      setState(() {
        _currentUrl = currentUrl;
        _urlController.text = currentUrl;
        _detectedIP = detectedIP;
        _suggestedUrls = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load configuration: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a URL';
      });
      return;
    }

    // Validate URL
    if (!NetworkUtils.isValidUrl(url)) {
      setState(() {
        _errorMessage = 'Invalid URL format. Must start with http:// or https://';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _configService.saveWebAppUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuration saved: $url'),
            backgroundColor: Colors.green,
          ),
        );

        // Return to previous screen
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isSaving = false;
      });
    }
  }

  Future<void> _autoDetect() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detectedUrl = await _configService.autoDetectAndSave();

      if (detectedUrl != null) {
        setState(() {
          _urlController.text = detectedUrl;
          _currentUrl = detectedUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-detected: $detectedUrl'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Could not auto-detect network IP. Please enter manually.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Auto-detection failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _useSuggestion(String url) {
    setState(() {
      _urlController.text = url;
      _errorMessage = null;
    });
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a URL to test';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _configService.testConnection(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'URL format is valid'
                  : 'Connection test failed',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Test failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Configuration'),
        actions: [
          if (!_isLoading && !_isSaving)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload',
              onPressed: _loadConfiguration,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Local Network Setup',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Configure the web app URL for local testing. '
                            'Make sure your mobile device and computer are on the same WiFi network.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detected IP Info
                  if (_detectedIP != null)
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.wifi, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Device IP Address',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _detectedIP!,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // URL Input
                  const Text(
                    'Web App URL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'http://192.168.1.100:3000',
                      prefixIcon: const Icon(Icons.link),
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                      helperText: 'Enter your computer\'s IP address and port',
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    enabled: !_isSaving,
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _autoDetect,
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Auto-Detect'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _testConnection,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Test'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Suggested URLs
                  if (_suggestedUrls.isNotEmpty) ...[
                    const Text(
                      'Suggested URLs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_suggestedUrls.map((url) => Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.dns,
                              color: Colors.grey[600],
                            ),
                            title: Text(
                              url,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () => _useSuggestion(url),
                          ),
                        ))),
                    const SizedBox(height: 24),
                  ],

                  // Help Text
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.help_outline, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'How to find your IP address',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Mac: System Preferences → Network\n'
                            '• Windows: Settings → Network & Internet\n'
                            '• Linux: Run "ip addr" in terminal\n'
                            '• Look for your computer\'s local IP (starts with 192.168 or 10.)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveConfiguration,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Save Configuration',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
