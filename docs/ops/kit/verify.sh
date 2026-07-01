#!/usr/bin/env sh
# 이 레포의 "통과" 정의 = 이 스크립트가 exit 0. 기술스택 무관.
# 아래 검사 영역을 이 프로젝트의 실제 명령으로 교체한다.
# 비운 채로 두면 의도적으로 실패한다 → 검증 빈칸(즉흥 검증)을 원천 차단.
set -eu

# --- 게이트(스택 무관, 그대로 둠) ------------------------------------------
sh docs/ops/kit/spec-gate.sh      # In Progress PRD 필수칸 검사
sh docs/ops/kit/golden-gate.sh    # Done PLAN의 골든셋(/validate) 결과 검사

# --- 채우기: 이 프로젝트의 기술 검사로 교체 --------------------------------
# 예) pnpm install --frozen-lockfile && pnpm lint && pnpm typecheck && pnpm test && pnpm build
# 예) make lint test
# 예) uv run ruff check . && uv run pytest
# 예) cargo fmt --check && cargo clippy -- -D warnings && cargo test
echo "verify.sh 미구현: 기술 검사 명령으로 교체하세요(이 상태는 통과가 아님)" >&2; exit 1
# --------------------------------------------------------------------------
