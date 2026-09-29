#!/usr/bin/env sh
# [이식용 시드] 기존 프로젝트에 이 루프를 이식할 때 복사해 가는 verify.sh 시작점.
# **정본은 루트 verify.sh다.** 게이트 목록이 바뀌면 루트를 고치고 이 파일을 맞춘다
# (두 벌이면 반드시 어긋난다: v2.38 원칙. 실제로 이 파일이 게이트 2종에 멈춰 있어
#  이식받은 프로젝트가 절반만 검사받을 뻔했다 ─ v2.39 전수조사에서 발견).
#
# 이 레포의 "통과" 정의 = 이 스크립트가 exit 0. 기술스택 무관.
# 아래 검사 영역을 이 프로젝트의 실제 명령으로 교체한다.
# 비운 채로 두면 의도적으로 실패한다 → 검증 빈칸(즉흥 검증)을 원천 차단.
set -eu

# --- 게이트(스택 무관, 그대로 둠) ------------------------------------------
sh docs/ops/kit/spec-gate.sh         # 착수한 PLAN의 필수칸(목표·범위·수용기준) 검사
sh docs/ops/kit/golden-gate.sh       # 닫는 PLAN·내보내는 RELEASE의 골든셋(/validate) 결과 검사
sh docs/ops/kit/escalation-gate.sh   # 에스컬레이션 경로 빈칸 검사(1인이면 [SINGLE-AGENT] 면제)
sh docs/ops/kit/consistency-gate.sh  # CHANGELOG 최신 버전이 README에도 반영됐는지

# --- 채우기: 이 프로젝트의 기술 검사로 교체 --------------------------------
# 예) pnpm install --frozen-lockfile && pnpm lint && pnpm typecheck && pnpm test && pnpm build
# 예) make lint test
# 예) uv run ruff check . && uv run pytest
# 예) cargo fmt --check && cargo clippy -- -D warnings && cargo test
echo "verify.sh 미구현: 기술 검사 명령으로 교체하세요(이 상태는 통과가 아님)" >&2; exit 1
# --------------------------------------------------------------------------

# stop-verify-gate 훅(켜져 있으면)이 참조하는 검증 흔적
mkdir -p .claude && touch .claude/.last-verify
