// Network Utilities
// Auto-detection of local IP addresses and network configuration helpers

import 'dart:io';

class NetworkUtils {
  /// Get the device's local IP address on the network
  /// Returns null if unable to detect
  static Future<String?> getLocalIPAddress() async {
    try {
      // Get all network interfaces
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      // Priority order: WiFi > Ethernet > Other
      // Look for common WiFi interface names first
      for (var interface in interfaces) {
        final name = interface.name.toLowerCase();
        if (name.contains('wlan') ||
            name.contains('wi-fi') ||
            name.contains('en0')) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
              return addr.address;
            }
          }
        }
      }

      // Fallback: return first non-loopback IPv4 address
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error detecting local IP: $e');
      return null;
    }
  }

  /// Validate if a URL is properly formatted
  /// Returns true if valid, false otherwise
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);

      // Must have http or https scheme
      if (!['http', 'https'].contains(uri.scheme)) {
        return false;
      }

      // Must have a host
      if (uri.host.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Build a web app URL from IP address and port
  /// Example: buildWebUrl('192.168.1.100', 3000) -> 'http://192.168.1.100:3000'
  static String buildWebUrl(String ipAddress, int port) {
    return 'http://$ipAddress:$port';
  }

  /// Extract host and port from URL
  /// Returns map with 'host' and 'port' keys, or null if invalid
  static Map<String, dynamic>? parseWebUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return {
        'host': uri.host,
        'port': uri.port > 0 ? uri.port : (uri.scheme == 'https' ? 443 : 80),
        'scheme': uri.scheme,
      };
    } catch (e) {
      return null;
    }
  }

  /// Check if IP address is a local/private network address
  static bool isLocalIPAddress(String ip) {
    // Check common private IP ranges:
    // 10.0.0.0 - 10.255.255.255
    // 172.16.0.0 - 172.31.255.255
    // 192.168.0.0 - 192.168.255.255
    // 127.0.0.0 - 127.255.255.255 (localhost)

    if (ip.startsWith('10.')) return true;
    if (ip.startsWith('192.168.')) return true;
    if (ip.startsWith('127.')) return true;

    // Check 172.16-31 range
    if (ip.startsWith('172.')) {
      final parts = ip.split('.');
      if (parts.length >= 2) {
        final second = int.tryParse(parts[1]);
        if (second != null && second >= 16 && second <= 31) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get suggested web app URLs based on local IP
  /// Returns list of suggested URLs to try
  static Future<List<String>> getSuggestedWebUrls() async {
    final suggestions = <String>[];

    // Add localhost option
    suggestions.add('http://localhost:3000');

    // Try to detect local IP
    final localIP = await getLocalIPAddress();
    if (localIP != null) {
      suggestions.add('http://$localIP:3000');
    }

    // Add common local IP patterns as fallbacks
    suggestions.add('http://192.168.1.1:3000');
    suggestions.add('http://192.168.0.1:3000');

    return suggestions;
  }
}
