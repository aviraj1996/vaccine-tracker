// Network Configuration Service
// Manages API URL configuration with persistence using SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import '../utils/network_utils.dart';

class NetworkConfigService {
  // Singleton pattern
  static final NetworkConfigService _instance =
      NetworkConfigService._internal();
  factory NetworkConfigService() => _instance;
  NetworkConfigService._internal();

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Storage key
  static const String _webAppUrlKey = 'web_app_url';

  // Default URL (fallback)
  static const String _defaultUrl = 'http://localhost:3000';

  /// Initialize the service (call this on app startup)
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the configured web app URL
  /// Returns saved URL or default if not configured
  Future<String> getWebAppUrl() async {
    if (_prefs == null) {
      await initialize();
    }

    final savedUrl = _prefs?.getString(_webAppUrlKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      return savedUrl;
    }

    // Try auto-detection as fallback
    final localIP = await NetworkUtils.getLocalIPAddress();
    if (localIP != null) {
      return NetworkUtils.buildWebUrl(localIP, 3000);
    }

    return _defaultUrl;
  }

  /// Save web app URL to persistent storage
  /// Validates URL before saving
  Future<bool> saveWebAppUrl(String url) async {
    if (_prefs == null) {
      await initialize();
    }

    // Validate URL format
    if (!NetworkUtils.isValidUrl(url)) {
      throw Exception('Invalid URL format. Must start with http:// or https://');
    }

    // Save to preferences
    final success = await _prefs?.setString(_webAppUrlKey, url) ?? false;
    return success;
  }

  /// Clear saved web app URL
  Future<bool> clearWebAppUrl() async {
    if (_prefs == null) {
      await initialize();
    }

    return await _prefs?.remove(_webAppUrlKey) ?? false;
  }

  /// Check if a custom URL is configured
  Future<bool> hasCustomUrl() async {
    if (_prefs == null) {
      await initialize();
    }

    final savedUrl = _prefs?.getString(_webAppUrlKey);
    return savedUrl != null && savedUrl.isNotEmpty;
  }

  /// Test connection to web app URL
  /// Returns true if connection successful
  Future<bool> testConnection(String url) async {
    try {
      // TODO: Implement actual HTTP request to test connection
      // For now, just validate the URL format
      return NetworkUtils.isValidUrl(url);
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Get suggested URLs based on network detection
  Future<List<String>> getSuggestedUrls() async {
    return await NetworkUtils.getSuggestedWebUrls();
  }

  /// Auto-detect and save best guess URL
  Future<String?> autoDetectAndSave() async {
    final localIP = await NetworkUtils.getLocalIPAddress();
    if (localIP != null) {
      final url = NetworkUtils.buildWebUrl(localIP, 3000);
      await saveWebAppUrl(url);
      return url;
    }
    return null;
  }
}
