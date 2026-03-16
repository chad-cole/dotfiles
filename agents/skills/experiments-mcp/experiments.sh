#!/usr/bin/env bash
# experiments.sh - CLI wrapper for the Shopify experiments MCP server
# Usage: experiments.sh <tool_name> [--param value ...]
#
# Examples:
#   experiments.sh search --query "my_flag" --include_flags true
#   experiments.sh flag_create --handle "f_my_flag" --title "My Flag" --subject_type shop
#   experiments.sh flag_status --flag_handle "f_my_flag"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# MCP server config
export MCP_API_TOKEN="${MCP_API_TOKEN:-019cf829-1d82-74ef-9c08-64b8ecf33acc}"
export MCP_TARGET_URL="${MCP_TARGET_URL:-https://experiments.shopify.com/api/mcp}"
MCP_BRIDGE="${MCP_BRIDGE:-/opt/homebrew/bin/uvx}"
MCP_BRIDGE_ARGS="shopify-mcp-bridge"

if [[ $# -lt 1 ]]; then
  echo "Usage: experiments.sh <tool_name> [--param value ...]" >&2
  echo "" >&2
  echo "Available tools:" >&2
  echo "  search, flag_create, flag_edit, flag_status," >&2
  echo "  experiment_create, experiment_edit, experiment_status, experiment_details," >&2
  echo "  bandit_status, manual_assignments," >&2
  echo "  metric_create, metric_status, metric_update," >&2
  echo "  segment_create, segment_status, segment_update," >&2
  echo "  documentation, enrich_metadata" >&2
  exit 1
fi

TOOL_NAME="$1"
shift

# Parse --key value pairs into JSON arguments
ARGS="{}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --*)
      KEY="${1#--}"
      if [[ $# -lt 2 ]]; then
        echo "Error: missing value for --$KEY" >&2
        exit 1
      fi
      VALUE="$2"
      shift 2

      # Known integer parameters
      INTEGER_KEYS="team_id champion_id project_id page percentile follow_up_days"

      # Detect booleans, known integer params, arrays/objects; otherwise treat as string
      if [[ "$VALUE" == "true" ]]; then
        ARGS=$(echo "$ARGS" | python3 -c "import sys,json; d=json.load(sys.stdin); d['$KEY']=True; print(json.dumps(d))")
      elif [[ "$VALUE" == "false" ]]; then
        ARGS=$(echo "$ARGS" | python3 -c "import sys,json; d=json.load(sys.stdin); d['$KEY']=False; print(json.dumps(d))")
      elif [[ "$VALUE" =~ ^-?[0-9]+$ ]] && [[ " $INTEGER_KEYS " == *" $KEY "* ]]; then
        ARGS=$(echo "$ARGS" | python3 -c "import sys,json; d=json.load(sys.stdin); d['$KEY']=$VALUE; print(json.dumps(d))")
      elif [[ "$VALUE" == \[* || "$VALUE" == \{* ]]; then
        ARGS=$(echo "$ARGS" | python3 -c "import sys,json; d=json.load(sys.stdin); d['$KEY']=json.loads('$VALUE'); print(json.dumps(d))")
      else
        ARGS=$(echo "$ARGS" | python3 -c "import sys,json; d=json.load(sys.stdin); d['$KEY']=sys.argv[1]; print(json.dumps(d))" "$VALUE")
      fi
      ;;
    *)
      echo "Error: unexpected argument '$1' (use --key value format)" >&2
      exit 1
      ;;
  esac
done

# Build the JSON-RPC messages
INIT_MSG='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"pi-experiments","version":"1.0"}}}'
CALL_MSG=$(python3 -c "
import json
msg = {
    'jsonrpc': '2.0',
    'id': 2,
    'method': 'tools/call',
    'params': {
        'name': '$TOOL_NAME',
        'arguments': json.loads('$ARGS')
    }
}
print(json.dumps(msg))
")

# Send both messages to the MCP server via stdin and capture output
RESPONSE=$(printf '%s\n%s\n' "$INIT_MSG" "$CALL_MSG" | \
  "$MCP_BRIDGE" $MCP_BRIDGE_ARGS 2>/dev/null)

# The response has two lines (init response + tool response). Extract the tool response.
TOOL_RESPONSE=$(echo "$RESPONSE" | tail -1)

# Pretty-print the result
python3 -c "
import sys, json

try:
    data = json.loads(sys.argv[1])
except json.JSONDecodeError:
    print('Error: failed to parse MCP response')
    print(sys.argv[1])
    sys.exit(1)

if 'error' in data:
    print(f'Error: {json.dumps(data[\"error\"], indent=2)}')
    sys.exit(1)

result = data.get('result', {})
content = result.get('content', [])
for item in content:
    if item.get('type') == 'text':
        text = item['text']
        # Try to pretty-print if it's JSON
        try:
            parsed = json.loads(text)
            print(json.dumps(parsed, indent=2))
        except (json.JSONDecodeError, TypeError):
            print(text)
    else:
        print(json.dumps(item, indent=2))
" "$TOOL_RESPONSE"
