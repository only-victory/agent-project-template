#!/bin/sh
# stop-verify-gate (Stop 훅, 기본 꺼짐): "검증 없이 세션 마무리" 차단.
# 원리: verify.sh가 성공 시 남기는 흔적(.claude/.last-verify)보다 나중에 수정된
#       추적 파일이 있으면 = 검증이 낡음(stale) → 응답 종료를 막고 검증 요구.
# 활성화: .claude/hooks/HOOKS.md 참고. 무한 차단 방지: stop_hook_active면 즉시 통과.
#
# v2.51: "진행 중 작업이 있나" 판정을 plan-status.sh(단일 판정기)로 교체.
#   이전엔 docs/plans/*.md 전체를 영문 "In Progress" 문자열로 grep했다. 그래서
#   ① INDEX.md 범례 행("착수하면 In Progress |")에 항상 걸려 켜는 순간 매 종료를 막았고
#   ② 한글 상태("착수"·"진행 중")는 못 봤다. 이제 게이트와 같은 판정·같은 어휘를 쓴다.
payload=$(cat)
printf '%s' "$payload" | grep -q '"stop_hook_active": *true' && exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

status=$(sh docs/ops/kit/plan-status.sh 2>&1) || {
  printf '[stop-verify-gate] 상태 판정기 실패: %s\n' "$status" >&2
  exit 2
}
# open(착수·진행 중) PLAN이 없으면 검증 의무 없음 (문서 작업 등)
printf '%s\n' "$status" | awk -F '\t' '$2 == "1" { found = 1 } END { exit !found }' || exit 0
command -v git >/dev/null 2>&1 || exit 0

sentinel=.claude/.last-verify
if [ ! -f "$sentinel" ]; then
  printf '[stop-verify-gate] 진행 중 작업이 있는데 검증 실행 흔적(.claude/.last-verify)이 없습니다. sh verify.sh 를 실행해 통과시킨 뒤 마무리하세요. (검증이 불가한 상황이면 그 사유를 blocked/uncertain으로 보고)\n' >&2
  exit 2
fi

# 검증 이후에 또 수정된 추적 파일이 있나 (코드만: docs·.md 수정은 면제)
# -z 형식: 경로를 따옴표로 감싸지 않는다(공백 경로 "my app.js"가 그대로 나옴).
#   이름 변경(R·C)은 "XY 새경로" 다음 레코드가 옛경로라 그 레코드는 건너뛴다.
stale=$(git status --porcelain -z 2>/dev/null | tr '\0' '\n' | awk 'skip { skip = 0; next } { if (substr($0, 1, 2) ~ /[RC]/) skip = 1; print substr($0, 4) }' | grep -v '^docs/' | grep -v '\.md$' | while IFS= read -r f; do
  [ -f "$f" ] && [ "$f" -nt "$sentinel" ] && echo "$f" && break
done)
if [ -n "$stale" ]; then
  printf '[stop-verify-gate] 마지막 검증 이후 수정된 파일이 있습니다(예: %s). sh verify.sh 재실행 후 마무리하세요.\n' "$stale" >&2
  exit 2
fi
exit 0
