#!/usr/bin/env node

// Show Network Information Script
// Displays local IP address when Next.js dev server starts

const { networkInterfaces } = require('os');

function getLocalIPAddress() {
  const nets = networkInterfaces();

  // Priority interfaces
  const priority = ['en0', 'wlan0', 'eth0'];

  for (const name of priority) {
    const addresses = nets[name];
    if (addresses) {
      for (const addr of addresses) {
        if (addr.family === 'IPv4' && !addr.internal) {
          return addr.address;
        }
      }
    }
  }

  // Fallback: any non-internal IPv4
  for (const name of Object.keys(nets)) {
    const addresses = nets[name];
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

const ip = getLocalIPAddress();

if (ip) {
  console.log('\n' + '='.repeat(60));
  console.log('🌐  Local Network Access');
  console.log('='.repeat(60));
  console.log(`\n  Local:            http://localhost:3000`);
  console.log(`  Network:          http://${ip}:3000\n`);
  console.log('📱  Mobile Device Setup:');
  console.log(`  1. Connect to same WiFi network`);
  console.log(`  2. Open mobile app > Settings`);
  console.log(`  3. Enter: http://${ip}:3000`);
  console.log('='.repeat(60) + '\n');
}
