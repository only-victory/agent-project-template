#!/usr/bin/env sh
# 이 파일은 '사용자 프로젝트'의 검사 진입점이자 게이트 목록의 정본이다.
# (템플릿 배포 레포 자체의 CI는 이 파일을 돌리지 않는다: 미구현이 정상 상태라서.
#  템플릿 CI는 게이트 4종만 돌려 '템플릿 자체'를 검사한다.)
# 이 레포의 "통과" 정의 = exit 0. 스택 무관.
#
# v2.38: 게이트 목록을 여기 하나로 모았다.
#   이전엔 이 파일이 게이트 2개(spec·golden)만 돌리고, CI(ci.example.yml)가
#   다른 4개(spec·golden·escalation·consistency)를 따로 돌았다. 겹치는 건
#   둘뿐이라 어느 쪽도 전부를 보지 않았다: 실사용에서 실제로 발견된 사고다.
#   목록이 두 벌이면 반드시 어긋난다. 이제 정본은 여기 하나고, CI는 이 파일을
#   그대로 돌린다(ci.example.yml 참고).
set -eu
# 1) 명세 게이트: 착수한 PLAN의 필수칸(목표·범위·수용기준)이 비면 fail
sh docs/ops/kit/spec-gate.sh
# 2) 골든셋 게이트: 닫는 PLAN·내보내는 RELEASE에 /validate 결과가 없으면 fail
sh docs/ops/kit/golden-gate.sh
# 3) 에스컬레이션 경로가 빈칸이면 fail (1인이면 [SINGLE-AGENT] 마커로 면제)
sh docs/ops/kit/escalation-gate.sh
# 4) 요약부 정합: CHANGELOG 최신 버전이 README에도 반영됐는가
sh docs/ops/kit/consistency-gate.sh
# 5) 이 프로젝트 검사: 아래를 이 레포의 실제 검사 명령으로 교체 (스택 무관)
#    스택별 시작점: docs/ops/kit/recipes/ (Node/Python/GAS/정적웹)
#    여러 스택을 함께 쓰면 레시피를 이어 붙인다 (recipes/README.md '혼용' 참고)
echo "verify.sh 미구현: 5)를 실제 검사 명령으로 교체하세요(이 상태는 통과 아님)" >&2; exit 1

# stop-verify-gate 훅(켜져 있으면)이 참조하는 검증 흔적
mkdir -p .claude && touch .claude/.last-verify
