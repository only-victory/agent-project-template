#!/bin/sh
# consistency-gate: README 요약부가 본체(CHANGELOG)를 따라오는지 확인.
# 배경: "본체는 갱신되는데 README 히스토리가 조용히 뒤처지는" lag가 3회 반복됨(retro 임계 충족).
# 원리: docs/plans/CHANGELOG.md의 최신 버전이 README.md 버전 히스토리에 존재해야 한다.
#
# v2.37: 버전 패턴을 못 찾으면 "SKIP + exit 0"이 아니라 "FAIL + exit 1"이다.
#   이유(실마찰): 조용히 통과하는 게 제일 나쁜 실패다. 이 레포의 CHANGELOG 서식이
#   "## v1.8.0" 표준과 다르면(예: "## 뭉실 프로젝트: 2026-08-12"), 게이트가 아무것도 못
#   봤다는 사실 자체가 사람에게 보고돼야 한다 ─ 통과 도장을 찍어주면 안 된다.
#   서식이 다른 프로젝트는 아래 대체 규칙 중 하나를 쓴다.

latest=$(grep -oE '^## v[0-9]+\.[0-9]+' docs/plans/CHANGELOG.md | head -1 | sed 's/^## //; s/\.0$//')

if [ -z "$latest" ]; then
  echo "consistency-gate FAIL: docs/plans/CHANGELOG.md에서 '## vX.Y' 형식의 버전을 못 찾음" >&2
  echo "  이 레포의 CHANGELOG 서식이 표준(## v1.8.0)과 다르면 둘 중 하나로 해결:" >&2
  echo "  (a) CHANGELOG 최신 항목 제목에 '## v1.8.0' 형식을 병기한다 (가장 빠름)" >&2
  echo "  (b) 이 스크립트의 버전 정규식을 이 레포 서식에 맞게 바꾸고, 그 사실을 CHANGELOG에 한 줄 남긴다" >&2
  echo "  못 찾았다고 통과시키지 않는다: 조용한 통과가 이 게이트가 막으려는 사고다" >&2
  exit 1
fi

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
