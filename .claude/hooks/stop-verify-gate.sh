#!/bin/sh
# stop-verify-gate (Stop 훅, 기본 꺼짐): "검증 없이 세션 마무리" 차단.
# 원리: verify.sh가 성공 시 남기는 흔적(.claude/.last-verify)보다 나중에 수정된
#       추적 파일이 있으면 = 검증이 낡음(stale) → 응답 종료를 막고 검증 요구.
# 활성화: .claude/hooks/HOOKS.md 참고. 무한 차단 방지: stop_hook_active면 즉시 통과.
payload=$(cat)
printf '%s' "$payload" | grep -q '"stop_hook_active": *true' && exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

# In Progress PLAN이 없으면 검증 의무 없음 (문서 작업 등)
grep -rq "상태: In Progress\|In Progress |" docs/plans/*.md 2>/dev/null || exit 0
command -v git >/dev/null 2>&1 || exit 0

sentinel=.claude/.last-verify
if [ ! -f "$sentinel" ]; then
  printf '[stop-verify-gate] In Progress 작업이 있는데 검증 실행 흔적(.claude/.last-verify)이 없습니다. sh verify.sh 를 실행해 통과시킨 뒤 마무리하세요. (검증이 불가한 상황이면 그 사유를 blocked/uncertain으로 보고)\n' >&2
  exit 2
fi

# 검증 이후에 또 수정된 추적 파일이 있나 (src·코드만: docs 수정은 면제)
stale=$(git status --porcelain 2>/dev/null | awk '{print $2}' | grep -v "^docs/\|\.md$" | while read f; do
  [ -f "$f" ] && [ "$f" -nt "$sentinel" ] && echo "$f" && break
done)
if [ -n "$stale" ]; then
  printf '[stop-verify-gate] 마지막 검증 이후 수정된 파일이 있습니다(예: %s). sh verify.sh 재실행 후 마무리하세요.\n' "$stale" >&2
  exit 2
fi
exit 0
