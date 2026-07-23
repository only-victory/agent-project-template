#!/bin/sh
# consistency-gate: README 요약부가 본체(CHANGELOG)를 따라오는지 확인.
# 배경: "본체는 갱신되는데 README 히스토리가 조용히 뒤처지는" lag가 3회 반복됨(retro 임계 충족).
# 원리: docs/plans/CHANGELOG.md의 최신 버전이 README.md 버전 히스토리에 존재해야 한다.

latest=$(grep -oE '^## v[0-9]+\.[0-9]+' docs/plans/CHANGELOG.md | head -1 | sed 's/^## //; s/\.0$//')
[ -z "$latest" ] && { echo "consistency-gate SKIP (CHANGELOG에서 버전 못 찾음)"; exit 0; }

fail=0
if ! grep -q "\*\*${latest}\*\*" README.md; then
  echo "consistency-gate 실패: README 버전 히스토리에 ${latest} 없음 (요약부 lag)"; fail=1
fi
if ! grep -q "^## ${latest}" CHANGELOG.md; then
  echo "consistency-gate 실패: 루트 CHANGELOG.md에 ${latest} 스토리 없음 (세 번째 lag 사각지대 방지)"; fail=1
fi
if [ "$fail" = "0" ]; then
  echo "consistency-gate OK (README·루트 CHANGELOG 모두 ${latest} 존재)"
else
  echo "consistency-gate FAIL: 위 항목을 갱신한 뒤 다시 실행" >&2
  exit 1
fi
