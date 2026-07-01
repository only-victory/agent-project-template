#!/usr/bin/env sh
# 이 레포의 "통과" 정의 = exit 0. 스택 무관.
set -eu
# 1) 명세 게이트: In Progress PRD의 필수칸(목표·범위·성공기준)이 비면 fail
sh docs/ops/kit/spec-gate.sh
# 2) 골든셋 게이트: Done으로 닫는 PLAN에 의미 검증(/validate) 결과가 없으면 fail
sh docs/ops/kit/golden-gate.sh
# 3) 이 프로젝트 검사: 아래를 이 레포의 실제 명령으로 교체 (스택 무관)
#    스택별 시작점: docs/ops/kit/recipes/ (Node/Python/GAS/정적웹)
#    여러 스택을 함께 쓰면 레시피를 이어 붙인다 (recipes/README.md '혼용' 참고)
echo "verify.sh 미구현: 3)을 실제 검사 명령으로 교체하세요(이 상태는 통과 아님)" >&2; exit 1
