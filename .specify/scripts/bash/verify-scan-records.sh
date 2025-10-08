#!/bin/bash
# Verify scan records in Supabase database

echo "🔍 Verifying Scan Records in Supabase Database"
echo "=============================================="
echo ""

SUPABASE_URL="https://bsdpgfhthdkuwihoomdk.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHBnZmh0aGRrdXdpaG9vbWRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzAxMzMsImV4cCI6MjA3NTIwNjEzM30.I-_3doMqZtW3zbkXjofw18jorGONXDNUSG0SKHwwuNc"

# Check QR Codes
echo "📋 Checking QR Codes Table:"
echo "----------------------------"
curl -s "${SUPABASE_URL}/rest/v1/qr_codes?select=id,gtin,batch,serial,created_at&order=created_at.desc&limit=5" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  | python3 -m json.tool

echo ""
echo ""

# Check Scan Events (most recent)
echo "📱 Checking Recent Scan Events (Last 10):"
echo "------------------------------------------"
curl -s "${SUPABASE_URL}/rest/v1/scan_events?select=id,qr_code_id,scanned_by,scanned_at,device_info&order=scanned_at.desc&limit=10" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  | python3 -m json.tool

echo ""
echo ""

# Count totals
echo "📊 Database Statistics:"
echo "-----------------------"
echo -n "Total QR Codes: "
curl -s "${SUPABASE_URL}/rest/v1/qr_codes?select=count" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Prefer: count=exact" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['count'])"

echo -n "Total Scan Events: "
curl -s "${SUPABASE_URL}/rest/v1/scan_events?select=count" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Prefer: count=exact" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)[0]['count'])"

echo ""
echo "✅ Verification complete!"
