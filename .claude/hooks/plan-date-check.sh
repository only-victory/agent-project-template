#!/bin/sh
# plan-date-check (PostToolUse): PLAN/PRD를 수정하고 날짜 헤더를 안 갱신하면 알림.
# doc-sync의 "수정 시 최종수정일 갱신" 지침을 센서로. exit 2 = Claude에게 stderr 전달(차단 아님, 이미 실행됨).
payload=$(cat)
fp=$(printf '%s' "$payload" | grep -o '"file_path"[^,}]*' | head -1 | sed 's/.*: *"//; s/"$//')
[ -z "$fp" ] && exit 0

case "$fp" in
  */docs/plans/PLAN-*.md|*/docs/specs/PRD.md|docs/plans/PLAN-*.md|docs/specs/PRD.md) ;;
  *) exit 0 ;;
esac
[ -f "$fp" ] || exit 0
grep -q "최종 수정" "$fp" || exit 0

today=$(date +%Y-%m-%d)
if ! grep "최종 수정" "$fp" | head -1 | grep -q "$today"; then
  printf '[doc-sync 센서] %s 를 수정했는데 헤더의 "최종 수정"이 오늘(%s)이 아닙니다. 날짜를 갱신하세요.\n' "$fp" "$today" >&2
  exit 2
fi
exit 0
