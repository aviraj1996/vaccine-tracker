#!/bin/bash

# Get QR codes from Supabase
echo "Fetching QR codes..."
SERIAL=$(curl -s "https://bsdpgfhthdkuwihoomdk.supabase.co/rest/v1/qr_codes?select=serial&limit=1" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHBnZmh0aGRrdXdpaG9vbWRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzAxMzMsImV4cCI6MjA3NTIwNjEzM30.I-_3doMqZtW3zbkXjofw18jorGONXDNUSG0SKHwwuNc" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHBnZmh0aGRrdXdpaG9vbWRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzAxMzMsImV4cCI6MjA3NTIwNjEzM30.I-_3doMqZtW3zbkXjofw18jorGONXDNUSG0SKHwwuNc" | jq -r '.[0].serial')

echo "Using serial: $SERIAL"

# Test 1: POST /api/scan
echo -e "\n\n=== Test 1: POST /api/scan ==="
curl -X POST http://localhost:3000/api/scan \
  -H "Content-Type: application/json" \
  -d "{\"serial\":\"$SERIAL\",\"scanned_by\":\"test@example.com\",\"device_info\":\"Test Device\"}" \
  -s | jq '.'

# Test 2: GET /api/scans/user/[email]
echo -e "\n\n=== Test 2: GET /api/scans/user/test@example.com ==="
curl -s "http://localhost:3000/api/scans/user/test@example.com?limit=5" | jq '.'

# Test 3: GET /api/qr/[id]
echo -e "\n\n=== Test 3: GET /api/qr/[id] ==="
QR_ID=$(curl -s "https://bsdpgfhthdkuwihoomdk.supabase.co/rest/v1/qr_codes?select=id&limit=1" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHBnZmh0aGRrdXdpaG9vbWRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzAxMzMsImV4cCI6MjA3NTIwNjEzM30.I-_3doMqZtW3zbkXjofw18jorGONXDNUSG0SKHwwuNc" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHBnZmh0aGRrdXdpaG9vbWRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzAxMzMsImV4cCI6MjA3NTIwNjEzM30.I-_3doMqZtW3zbkXjofw18jorGONXDNUSG0SKHwwuNc" | jq -r '.[0].id')

echo "Using QR ID: $QR_ID"
curl -s "http://localhost:3000/api/qr/$QR_ID" | jq '.'

# Test 4: Error cases
echo -e "\n\n=== Test 4: POST /api/scan with invalid serial ==="
curl -X POST http://localhost:3000/api/scan \
  -H "Content-Type: application/json" \
  -d '{"serial":"INVALID","scanned_by":"test@example.com"}' \
  -s | jq '.'

echo -e "\n\n=== Test 5: GET /api/scans/user/[email] with invalid email ==="
curl -s "http://localhost:3000/api/scans/user/invalid-email" | jq '.'

echo -e "\n\n=== Test 6: GET /api/qr/[id] with nonexistent ID ==="
curl -s "http://localhost:3000/api/qr/00000000-0000-0000-0000-000000000000" | jq '.'

echo -e "\n\nAll tests completed!"
