#!/usr/bin/env sh
# 에스컬레이션 경로 게이트: multi-agent.md의 "담당:" 줄이 빈 슬롯이면 exit 1.
# 단일 에이전트 프로젝트는 담당 줄에 [SINGLE-AGENT] 마커를 달면 면제된다.
# multi-agent.md가 없으면(멀티에이전트 미사용) 건너뜀.
MA=docs/ops/multi-agent.md
[ -f "$MA" ] || { echo "escalation OK (multi-agent 미사용)"; exit 0; }
DAMDANG=$(grep -E '^담당:' "$MA")
if printf '%s' "$DAMDANG" | grep -q '\[SINGLE-AGENT\]'; then
  echo "escalation OK (single-agent 면제)"; exit 0
fi
if printf '%s' "$DAMDANG" | grep -qE '<이름 또는 팀>'; then
  echo "에스컬레이션 게이트 실패: multi-agent.md의 '담당:' 줄을 채우거나 [SINGLE-AGENT] 마커를 다세요" >&2
  exit 1
fi
echo "escalation OK"; exit 0
