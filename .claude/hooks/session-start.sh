#!/bin/sh
# session-start: 세션 시작 시 "어디까지 했나"를 컨텍스트에 자동 주입.
# 지침("세션 시작 시 roadmap·PLAN 상태 읽기")을 기계화: 읽었겠지가 아니라 읽혀 있음.
# 실패해도 세션에 해가 없도록 모든 단계가 방어적이고 항상 exit 0. (stdout이 컨텍스트로 들어감)
#
# v2.51:
#   ① ROADMAP 위치를 docs/specs 하나로 고정하지 않는다. 템플릿이 위치를 정하지 않아
#      루트에 둔 레포에선 한 번도 안 읽혔다. 루트 → docs/specs → docs/plans 순으로 찾고
#      docs/ops(운영 지침: roadmap.md 서식 설명)는 보지 않는다.
#   ② 진행 중·막힌 PLAN은 INDEX.md grep이 아니라 plan-status.sh(게이트와 같은 판정기)로.
#      이전엔 INDEX 예시 행(<PLAN-예시.md>)이 매번 주입됐고 한글 상태("착수")는 못 봤다.
#   ③ /run 진행 원장의 "다음 착수"를 보여준다. 재개 지점이 원장에만 있어 매번 찾아 읽어야 했다.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

echo "[세션 위치 복원 - session-start 훅 자동 주입]"

roadmap=""
for d in . docs/specs docs/plans; do
  for f in "$d"/ROADMAP*.md; do
    [ -f "$f" ] && { roadmap=${f#./}; break 2; }
  done
done
if [ -n "$roadmap" ]; then
  pos=$(grep -A4 "현재 위치" "$roadmap" 2>/dev/null | head -6)
  if [ -n "$pos" ]; then
    echo "- 로드맵 현재 위치 ($roadmap):"
    printf '%s\n' "$pos" | sed 's/^/    /'
  else
    echo "- 로드맵: $roadmap (\"현재 위치\" 절 없음)"
  fi
fi

if [ -f docs/ops/kit/plan-status.sh ]; then
  # 판정기 실패는 조용히 넘기지 않는다(fail-closed). 세션은 막지 않고 경고만 주입.
  ps=$(sh docs/ops/kit/plan-status.sh 2>&1) || echo "- 경고: PLAN 상태 판정 실패. 게이트도 같은 이유로 실패함: $ps"
  wip=$(printf '%s\n' "$ps" | awk -F '\t' '
    $2 == "1" || $4 == "1" { tag = ($4 == "1") ? "막힘" : "진행"; print tag ": " $1 " (" $5 ")"; n++ }
    n >= 5 { exit }')
  [ -n "$wip" ] && { echo "- 진행 중/막힌 PLAN:"; printf '%s\n' "$wip" | sed 's/^/    /'; }
fi

if [ -f docs/plans/HANDOFF.md ]; then
  next=$(sed -n '/^## \/run 진행 원장/,/^## /p' docs/plans/HANDOFF.md 2>/dev/null | grep '^다음 착수' | tail -1)
  [ -n "$next" ] && echo "- /run 원장: $next (재개는 여기서)"
  last=$(grep '^## ' docs/plans/HANDOFF.md 2>/dev/null | grep -v '^## /run 진행 원장' | tail -1)
  [ -n "$last" ] && echo "- 최근 인수인계: $last (상세: docs/plans/HANDOFF.md)"
  if command -v git >/dev/null 2>&1; then
    h=$(git log -1 --format=%H -- docs/plans/HANDOFF.md 2>/dev/null)
    if [ -n "$h" ]; then
      n=$(git rev-list --count "$h"..HEAD 2>/dev/null)
      [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null && echo "    (주의: HANDOFF 갱신 뒤 커밋 ${n}개. 내용이 낡았을 수 있음)"
    fi
  fi
fi

echo "(위 정보 기반으로 이어서 진행. 없거나 어긋나면 memory-context §1 절차로 확인)"
exit 0
