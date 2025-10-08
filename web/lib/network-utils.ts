// Network Utilities
// Helper functions for network configuration and IP detection

import { networkInterfaces } from 'os';

/**
 * Get the local IP address of the server
 * Returns the first non-internal IPv4 address found
 */
export function getLocalIPAddress(): string | null {
  const nets = networkInterfaces();

  // Priority order: en0 (macOS WiFi) > wlan (Linux WiFi) > eth (Ethernet) > others
  const priorityInterfaces = ['en0', 'wlan0', 'eth0'];

  // First pass: check priority interfaces
  for (const interfaceName of priorityInterfaces) {
    const addresses = nets[interfaceName];
    if (addresses) {
      for (const addr of addresses) {
        if (addr.family === 'IPv4' && !addr.internal) {
          return addr.address;
        }
      }
    }
  }

  // Second pass: check all interfaces
  for (const interfaceName of Object.keys(nets)) {
    const addresses = nets[interfaceName];
    if (addresses) {
      for (const addr of addresses) {
        if (addr.family === 'IPv4' && !addr.internal) {
          return addr.address;
        }
      }
    }
  }

  return null;
}

/**
 * Get all local IP addresses
 * Useful for displaying multiple network interfaces
 */
export function getAllLocalIPAddresses(): Array<{interface: string, address: string}> {
  const nets = networkInterfaces();
  const results: Array<{interface: string, address: string}> = [];

  for (const interfaceName of Object.keys(nets)) {
    const addresses = nets[interfaceName];
    if (addresses) {
      for (const addr of addresses) {
        if (addr.family === 'IPv4' && !addr.internal) {
          results.push({
            interface: interfaceName,
            address: addr.address
          });
        }
      }
    }
  }

  return results;
}

/**
 * Build a complete URL with protocol, host and port
 */
export function buildServerUrl(ipAddress: string, port: number): string {
  return `http://${ipAddress}:${port}`;
}

/**
 * Check if an IP address is a private/local network address
 */
export function isPrivateIP(ip: string): boolean {
  const parts = ip.split('.');
  if (parts.length !== 4) return false;

  const first = parseInt(parts[0]);
  const second = parseInt(parts[1]);

  // 10.0.0.0 - 10.255.255.255
  if (first === 10) return true;

  // 172.16.0.0 - 172.31.255.255
  if (first === 172 && second >= 16 && second <= 31) return true;

  // 192.168.0.0 - 192.168.255.255
  if (first === 192 && second === 168) return true;

  // 127.0.0.0 - 127.255.255.255 (localhost)
  if (first === 127) return true;

  return false;
}
