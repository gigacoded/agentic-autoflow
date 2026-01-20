#!/bin/bash
# Start two Chrome instances for dual-account testing via MCP

# Kill any existing debug Chrome instances
pkill -f "chrome-profile-1|chrome-profile-2" 2>/dev/null
sleep 1

# Start Chrome 1 on port 9222
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/.chrome-profile-1" \
  --no-first-run &

# Start Chrome 2 on port 9223
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9223 \
  --user-data-dir="$HOME/.chrome-profile-2" \
  --no-first-run &

echo "Browsers started:"
echo "  chrome-1 -> port 9222 (profile: ~/.chrome-profile-1)"
echo "  chrome-2 -> port 9223 (profile: ~/.chrome-profile-2)"
