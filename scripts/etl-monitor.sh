#!/bin/bash
# =============================================================================
# EGOS Inteligência — ETL Progress Monitor v1.0
# Tracks CNPJ ETL progress and sends updates via Telegram
# Runs via cron every 10 minutes: */10 * * * * /opt/bracc/scripts/etl-monitor.sh
# =============================================================================

set -euo pipefail

LOG_FILE="/opt/bracc/logs/etl-monitor.log"
STATE_FILE="/opt/bracc/logs/etl-monitor-state.json"

if [ -f /opt/bracc/infra/.env ]; then
  set -a; source /opt/bracc/infra/.env; set +a
fi

NEO4J_PASS="${NEO4J_AUTH:-neo4j/neo4j}"
NEO4J_PASS="${NEO4J_PASS#*/}"

mkdir -p "$(dirname "$LOG_FILE")"

send_telegram() {
  local msg="$1"
  [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ] && return 0
  curl -sS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" -d "parse_mode=HTML" -d "text=${msg}" \
    --max-time 10 > /dev/null 2>&1 || true
}

# Check ETL process
ETL_PID=$(pgrep -f 'bracc-etl run.*cnpj' | head -1 || echo "")

# Get current counts
SOCIO_COUNT=$(timeout 10 docker exec bracc-neo4j cypher-shell -u neo4j -p "$NEO4J_PASS" \
  'MATCH ()-[r:SOCIO_DE]->() RETURN count(r) as c' --format plain 2>/dev/null | tail -1 || echo "0")
PERSON_COUNT=$(timeout 10 docker exec bracc-neo4j cypher-shell -u neo4j -p "$NEO4J_PASS" \
  'MATCH (p:Person) RETURN count(p) as c' --format plain 2>/dev/null | tail -1 || echo "0")
PARTNER_COUNT=$(timeout 10 docker exec bracc-neo4j cypher-shell -u neo4j -p "$NEO4J_PASS" \
  'MATCH (p:Partner) RETURN count(p) as c' --format plain 2>/dev/null | tail -1 || echo "0")

# Load previous state
PREV_SOCIO=0
if [ -f "$STATE_FILE" ]; then
  PREV_SOCIO=$(grep -o '"socio_de":[0-9]*' "$STATE_FILE" 2>/dev/null | cut -d: -f2 || echo "0")
fi

# Calculate delta
DELTA=$((SOCIO_COUNT - PREV_SOCIO))
TARGET=24600000  # 24.6M expected total
if [ "$SOCIO_COUNT" -gt 0 ] && [ "$TARGET" -gt 0 ]; then
  PCT=$((SOCIO_COUNT * 100 / TARGET))
else
  PCT=0
fi

# Save state
echo "{\"socio_de\":${SOCIO_COUNT},\"person\":${PERSON_COUNT},\"partner\":${PARTNER_COUNT},\"ts\":\"$(date -Iseconds)\"}" > "$STATE_FILE"

# Log
TS=$(date '+%Y-%m-%d %H:%M:%S')
if [ -n "$ETL_PID" ]; then
  ETL_CPU=$(ps -p "$ETL_PID" -o %cpu= 2>/dev/null | xargs || echo "?")
  ETL_MEM=$(ps -p "$ETL_PID" -o rss= 2>/dev/null | awk '{printf "%.1fGB", $1/1048576}' || echo "?")
  ETL_TIME=$(ps -p "$ETL_PID" -o etime= 2>/dev/null | xargs || echo "?")
  echo "[$TS] ETL running | SOCIO_DE: $SOCIO_COUNT (+$DELTA) | Person: $PERSON_COUNT | Partner: $PARTNER_COUNT | ${PCT}% | CPU:${ETL_CPU}% RAM:${ETL_MEM}" >> "$LOG_FILE"
else
  echo "[$TS] ETL stopped | SOCIO_DE: $SOCIO_COUNT | Person: $PERSON_COUNT | Partner: $PARTNER_COUNT | ${PCT}%" >> "$LOG_FILE"
  
  # Alert if ETL stopped and not at 100%
  if [ "$PCT" -lt 95 ] && [ "$PREV_SOCIO" -gt 0 ]; then
    send_telegram "⚠️ <b>ETL Stopped</b>
SOCIO_DE: ${SOCIO_COUNT} / ${TARGET} (${PCT}%)
Person: ${PERSON_COUNT} | Partner: ${PARTNER_COUNT}
<b>ETL process not running. May need restart.</b>
<code>ssh root@VPS</code>
<code>tmux attach -t etl</code>"
  fi
fi

# Milestone alerts (every 1M new relationships)
if [ "$DELTA" -gt 0 ] && [ $((SOCIO_COUNT % 1000000)) -lt "$DELTA" ] && [ "$SOCIO_COUNT" -gt 100000 ]; then
  MILLIONS=$((SOCIO_COUNT / 1000000))
  send_telegram "📊 <b>ETL Milestone</b>
SOCIO_DE: ${MILLIONS}M / 24.6M (${PCT}%)
Person: ${PERSON_COUNT} | Partner: ${PARTNER_COUNT}"
fi

# Completion alert
if [ "$PCT" -ge 95 ] && [ "$PREV_SOCIO" -lt $((TARGET * 95 / 100)) ]; then
  send_telegram "🎉 <b>ETL Near Complete!</b>
SOCIO_DE: ${SOCIO_COUNT} (${PCT}%)
Person: ${PERSON_COUNT} | Partner: ${PARTNER_COUNT}"
fi

# Trim log
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt 500 ]; then
  tail -n 200 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
