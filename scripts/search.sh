#!/bin/bash
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load .env
if [[ -f "$PROJECT_ROOT/.env" ]]; then
  set -a
  source "$PROJECT_ROOT/.env"
  set +a
fi

CURL="$(command -v curl)"
JQ="$(command -v jq)"

usage() {
  cat <<'USAGE'
Usage: search.sh <provider> <command> <query> [options]

Providers & Commands:
  tavily search   "query"  [--depth basic|advanced] [--max N] [--days N]
  tavily research "query"  [--max N] [--days N]
  tavily extract  "url1,url2,..."
  perplexity search   "query"  [--model sonar|sonar-pro]
  perplexity research "query"  [--model sonar-deep-research]
  perplexity reason   "query"  [--model sonar-reasoning-pro]

Options:
  --depth    Search depth for tavily search (default: advanced)
  --max      Max results for tavily (default: 10)
  --days     Recency filter in days for tavily
  --model    Perplexity model override

Environment:
  TAVILY_API_KEY       (or TAVILIY_API_KEY for backward compat)
  PERPLEXITY_API_KEY
USAGE
  exit 1
}

[[ $# -lt 3 ]] && usage

PROVIDER="$1"; shift
COMMAND="$1"; shift
QUERY="$1"; shift

# Parse optional args
DEPTH="advanced"
MAX_RESULTS=10
DAYS=""
MODEL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --depth) DEPTH="$2"; shift 2 ;;
    --max)   MAX_RESULTS="$2"; shift 2 ;;
    --days)  DAYS="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# --- Tavily ---

tavily_key() {
  local key="${TAVILY_API_KEY:-${TAVILIY_API_KEY:-}}"
  if [[ -z "$key" ]]; then
    echo '{"error":"TAVILY_API_KEY not set"}' >&2
    exit 1
  fi
  echo "$key"
}

tavily_search() {
  local key
  key=$(tavily_key)
  local body
  body=$($JQ -n \
    --arg query "$QUERY" \
    --arg api_key "$key" \
    --arg depth "$DEPTH" \
    --argjson max "$MAX_RESULTS" \
    '{api_key: $api_key, query: $query, search_depth: $depth, max_results: $max, include_raw_content: false}')

  if [[ -n "$DAYS" ]]; then
    body=$($JQ --argjson days "$DAYS" '. + {days: $days}' <<< "$body")
  fi

  $CURL -s -X POST "https://api.tavily.com/search" \
    -H "Content-Type: application/json" \
    -d "$body"
}

tavily_research() {
  DEPTH="advanced"
  local key
  key=$(tavily_key)
  local body
  body=$($JQ -n \
    --arg query "$QUERY" \
    --arg api_key "$key" \
    --argjson max "$MAX_RESULTS" \
    '{api_key: $api_key, query: $query, topic: "general", search_depth: "advanced", max_results: $max, include_raw_content: true}')

  if [[ -n "$DAYS" ]]; then
    body=$($JQ --argjson days "$DAYS" '. + {days: $days}' <<< "$body")
  fi

  $CURL -s -X POST "https://api.tavily.com/search" \
    -H "Content-Type: application/json" \
    -d "$body"
}

tavily_extract() {
  local key
  key=$(tavily_key)
  # QUERY contains comma-separated URLs
  local urls_json
  urls_json=$($JQ -n --arg urls "$QUERY" '$urls | split(",") | map(gsub("^\\s+|\\s+$";""))')
  local body
  body=$($JQ -n \
    --arg api_key "$key" \
    --argjson urls "$urls_json" \
    '{api_key: $api_key, urls: $urls}')

  $CURL -s -X POST "https://api.tavily.com/extract" \
    -H "Content-Type: application/json" \
    -d "$body"
}

# --- Perplexity ---

perplexity_key() {
  if [[ -z "${PERPLEXITY_API_KEY:-}" ]]; then
    echo '{"error":"PERPLEXITY_API_KEY not set"}' >&2
    exit 1
  fi
  echo "$PERPLEXITY_API_KEY"
}

perplexity_chat() {
  local model="$1"
  local key
  key=$(perplexity_key)
  local body
  body=$($JQ -n \
    --arg model "$model" \
    --arg query "$QUERY" \
    '{model: $model, messages: [{role: "user", content: $query}]}')

  $CURL -s -X POST "https://api.perplexity.ai/chat/completions" \
    -H "Authorization: Bearer $key" \
    -H "Content-Type: application/json" \
    -d "$body"
}

# --- Dispatch ---

case "$PROVIDER" in
  tavily)
    case "$COMMAND" in
      search)   tavily_search ;;
      research) tavily_research ;;
      extract)  tavily_extract ;;
      *) echo "Unknown tavily command: $COMMAND" >&2; exit 1 ;;
    esac
    ;;
  perplexity)
    case "$COMMAND" in
      search)   perplexity_chat "${MODEL:-sonar-pro}" ;;
      research) perplexity_chat "${MODEL:-sonar-deep-research}" ;;
      reason)   perplexity_chat "${MODEL:-sonar-reasoning-pro}" ;;
      *) echo "Unknown perplexity command: $COMMAND" >&2; exit 1 ;;
    esac
    ;;
  *) echo "Unknown provider: $PROVIDER" >&2; exit 1 ;;
esac
