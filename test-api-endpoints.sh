#!/bin/bash

# API Endpoint Testing Script for Phase 3.9
# Tests all new endpoints: /api/scan, /api/qr/:id, /api/scans/user/:email

echo "🧪 Testing Phase 3.9 API Endpoints"
echo "=================================="
echo ""

BASE_URL="http://localhost:3000"

# Test 1: POST /api/scan - Record a scan event
echo "Test 1: POST /api/scan"
echo "----------------------"
curl -s -X POST "$BASE_URL/api/scan" \
  -H "Content-Type: application/json" \
  -d '{
    "serial": "SN001",
    "scanned_by": "test@example.com",
    "device_info": "Test Device"
  }' | jq '.' 2>/dev/null || echo "Failed to parse JSON"
echo ""
echo ""

# Test 2: POST /api/scan - Invalid serial (should return 400)
echo "Test 2: POST /api/scan - Invalid Serial"
echo "----------------------------------------"
curl -s -X POST "$BASE_URL/api/scan" \
  -H "Content-Type: application/json" \
  -d '{
    "serial": "INVALID_SERIAL",
    "scanned_by": "test@example.com"
  }' | jq '.' 2>/dev/null || echo "Failed to parse JSON"
echo ""
echo ""

# Test 3: GET /api/qr/:id - Get QR by ID (we'll need a real ID from database)
echo "Test 3: GET /api/qr/:id"
echo "-----------------------"
echo "Getting a QR code ID from recent QR codes..."
QR_ID=$(curl -s "$BASE_URL/api/qr/generate/route.ts" 2>/dev/null | echo "Using test endpoint")
# For now, just show the endpoint format
echo "Endpoint: GET $BASE_URL/api/qr/{qr_code_id}"
echo "Example: curl $BASE_URL/api/qr/550e8400-e29b-41d4-a716-446655440000"
echo ""
echo ""

# Test 4: GET /api/scans/user/:email
echo "Test 4: GET /api/scans/user/:email"
echo "-----------------------------------"
curl -s "$BASE_URL/api/scans/user/test@example.com?limit=5" | jq '.' 2>/dev/null || echo "Failed to parse JSON"
echo ""
echo ""

# Test 5: GET /api/scans/user/:email - Invalid email
echo "Test 5: GET /api/scans/user/:email - Invalid Email"
echo "---------------------------------------------------"
curl -s "$BASE_URL/api/scans/user/invalid-email" | jq '.' 2>/dev/null || echo "Failed to parse JSON"
echo ""
echo ""

echo "✅ API Endpoint Tests Complete!"
echo "================================"
