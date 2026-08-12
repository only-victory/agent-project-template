# <PROJECT_NAME>: 에이전트 운영 계약

> Claude Code가 매 세션 자동 로드. 행동 정본·인터뷰·가드레일은 import, 본문은 이 레포 바인딩만.
> 크로스툴(Antigravity/Cursor)에서 쓰려면: 이 파일을 `AGENTS.md`로 복사(`cp CLAUDE.md AGENTS.md`)하거나
> Antigravity Rules에 Always On으로 등록. (한쪽만 둬서 중복 로딩·드리프트 방지)

@docs/ops/agent-loop.md
@docs/ops/spec-interview.md
@docs/ops/roadmap.md
@docs/ops/decision-support.md
@docs/ops/retro.md
@docs/ops/intent-routing.md
@docs/ops/guardrails.md
@docs/ops/doc-sync.md
@docs/ops/multi-agent.md
@docs/ops/memory-context.md

> 게이트 설계: `docs/ops/harness-design.md` · 협업원칙: `docs/specs/decisions/ADR-000-collaboration-principles.md`
> 골든셋(의미 검증): `docs/ops/golden-set.md` · 퀄리티 게이트·HITL·에스컬레이션: `docs/ops/multi-agent.md`
> UI 값 정본(화면 작업 시): `docs/specs/ui-tokens.md` · 모델 보정(opt-in, 켜려면 위 import에 추가): `docs/ops/model-calibration.md`
> 🔎 로드 카나리: 세션 시작 시 위 import가 안 보이면(/memory) 작업 전에 먼저 알린다.

## 1. 비협상 (요약 · 정본 = agent-loop)
- 명확한 지시엔 반론/되묻기/실행 중 하나. 묻기 전에 먼저 조사(코드·로그·문서).
- 막연하면 실행 금지 → spec-interview로 명세 먼저(경량 작업은 생략).
- 증거 없이 "완료" 금지 → §2 충족 + 출력 첨부. 테스트 통과만 시키는 건 검증 아님.
- 비가역·외부영향(삭제·배포·외부전송·실데이터·마이그레이션)은 계획→승인→실행.
- 작게: 파일 ~200줄·단일책임, YAGNI. 시크릿 비노출.
- 새 기술·디자인·보안 선택은 guardrails 기준 따르고, 벗어나면 ADR로 승인.
- 작업 끝낼 때 코드↔문서 불일치 점검 → 어긋나면 diff 제안하고 내 승인 후 갱신(doc-sync). 자동 덮어쓰기 금지.
- **막히면(재시도 3회 초과·비용 상한·성공 기준 충돌·보안 판단 필요) 즉시 멈추고 사람에게 (HITL).**

## 2. ⛳ 검증: "무엇을 보이면 통과인가"
- 기술 통과 = `./verify.sh` exit 0. **게이트 목록의 정본이 여기다**(게이트 4종 + 이 레포 검사): CI도 이 파일을 그대로 돌린다. 목록이 두 벌이면 반드시 어긋난다.
- 의미 통과 = `/validate` (골든셋 G1~G3 충족 → 결과 표 작성). **PLAN을 닫을 때도, RELEASE를 내보낼 때도 없으면 fail**(golden-gate.sh 강제. 상태 어휘는 done/완료/제출/배포/출시, 확장은 게이트 스크립트에서).
  - RELEASE는 **"배포 완료"가 아니라 "제출" 시점에** 문다: 배포 뒤에 검증하면 사용자가 이미 받은 뒤다.
- 퀄리티 게이트: **통과(Pass)** / **보류(Hold, 사람 판단)** / **재시도(Retry, ↺ 원인규명)** 셋 중 하나로만 보고.
- **모델을 바꿔도 합격선은 같다.** 능력 차이는 *통과까지 걸리는 시도 수*로 나타나야 하고 통과 기준으로 나타나선 안 된다. 게이트를 못 돌렸으면 **미검증**으로 보고한다(통과 아님). 정본: `agent-loop §1-1`.

## 3. 코드 지형
- 짝 규칙: `<예: 핸들러 수정 시 스키마·타입·호출부 같이>`
- 레이아웃: `<예: src/...>`

## 4. 위험 작업 (= '풀' 등급)
- `<예: prod 배포 · 마이그레이션 · 대량 삭제 · 외부 API write · 비밀 회전>`

## 5. 작업 진입점
- 신규 작업은 `docs/plans/prd.template.md` 복사 → 채움 → 루프 시작. (막연하면 /spec, 새 프로젝트면 /init-project)
- **자연어 우선**: 사용자는 명령어를 몰라도 된다. 평소 말("버그 고치고 싶어", "어디까지 했지?")로 하면 맞는 흐름으로 연결한다(`intent-routing.md`). 명령어를 강요하지 않는다. **단 모호하면 추측 말고 되묻고, 비가역 작업은 이해한 것을 되말하고 확인 후 실행.**
- **인터뷰 중엔: 고른 깊이의 모든 축을 다 묻고 사용자가 "이대로 진행"을 확인하기 전엔 코드·파일 생성 금지.** 매 질문에 [N/총축수] 진행 표시. 중간에 "충분하다"며 개발로 넘어가지 않는다.
- **화면(UI) 작업이면**: `docs/specs/ui-tokens.md`를 먼저 채우고, PRD `§6-3-1 화면 명세`(영역 구조·요소 개수·상태·버튼 변형)를 채운 뒤 구현한다. **명세가 비면 실행하지 않는다** ─ 비면 AI가 임의로 정한다. 구조를 말로 못 정하겠으면 시안 2~3개를 뽑아 고르게 한다.
- 완료 전 반드시 `/validate` 실행 (골든셋 의미 검증).
- 세션 인수인계 필요 시 `/handoff`. 막혔을 때는 `/escalate`.
- verify.sh 채울 때: `docs/ops/kit/recipes/` 스택별 시작점 참고(실제 명령으로 교체).
- 실서비스 운영 진입 시: `/ops-init`로 런북 활성화(opt-in), 장애 시 `/incident`.

## 6. 멀티에이전트 사용 시
- 역할(기획/실행/검토)은 사람이 지정. 에이전트가 자의로 역할 전환 금지.
- 담당 경로 밖 파일 수정 금지. 공유 경로는 사람 승인 후.
- 에스컬레이션 경로: `docs/ops/multi-agent.md §5` (반드시 채울 것)
