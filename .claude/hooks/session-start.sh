#!/bin/sh
# session-start: 세션 시작 시 "어디까지 했나"를 컨텍스트에 자동 주입.
# 지침("세션 시작 시 roadmap·INDEX 읽기")을 기계화: 읽었겠지가 아니라 읽혀 있음.
# 실패해도 세션에 해가 없도록 모든 단계가 방어적. (stdout이 컨텍스트로 들어감)
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

echo "[세션 위치 복원 - session-start 훅 자동 주입]"

if [ -f docs/specs/ROADMAP.md ]; then
  pos=$(grep -A4 "현재 위치" docs/specs/ROADMAP.md 2>/dev/null | head -6)
  [ -n "$pos" ] && { echo "- 로드맵 현재 위치:"; echo "$pos" | sed 's/^/    /'; }
fi

if [ -f docs/plans/INDEX.md ]; then
  wip=$(grep "| In Progress |\|| Blocked |" docs/plans/INDEX.md 2>/dev/null | grep -v '`' | head -5)
  [ -n "$wip" ] && { echo "- 진행 중/막힌 PLAN:"; echo "$wip" | sed 's/^/    /'; }
fi

if [ -f docs/plans/HANDOFF.md ]; then
  last=$(grep -m1 "^# 인수인계\|^## " docs/plans/HANDOFF.md 2>/dev/null)
  [ -n "$last" ] && echo "- 최근 인수인계 있음: $last (상세: docs/plans/HANDOFF.md)"
fi

echo "(위 정보 기반으로 이어서 진행. 없거나 어긋나면 memory-context §1 절차로 확인)"
exit 0
