# 시작하기 (입문자용)

이 템플릿은 "AI 에이전트와 안전하게 협업"하기 위한 폴더 골격이다.
세 관점이 폴더로 갈려 있다:
- **루프(행동)**: 에이전트가 매 작업 따르는 절차: `CLAUDE.md` + `docs/ops/agent-loop.md`
- **SDD(명세)**: 무엇을·왜·무엇이 끝인가: `docs/specs/`(제품) · `docs/plans/`(작업)
- **하네스(강제)**: 말이 아니라 실제로 막는 게이트: `verify.sh` · `.github/` · `.claude/`
- **품질(검증)**: 기술+의미 이중 검증: `verify.sh`(기술) + `golden-set.md`(/validate, 의미)
- **안전(중단)**: 막히면 멈추는 규칙: `multi-agent.md` (HITL · 에스컬레이션)

## 1) 1분 셋업
1. 압축을 풀고 폴더 이름을 프로젝트명으로 바꾼다.
2. `CLAUDE.md`·`README.md`의 `<...>` 슬롯을 채운다 (최소: 프로젝트명, 위험 작업 목록).
3. `verify.sh` 안의 한 줄을 이 프로젝트 실제 검사로 교체한다 (예: `npm run lint && npx tsc --noEmit && npm run build`).
4. `docs/ops/multi-agent.md §5` 에스컬레이션 경로를 채운다 (담당·채널·방식).
5. `sh setup-check.sh`로 빈칸이 없는지 확인한다. (남은 [ ] 항목을 채울수록 완성형)
6. 끝. 에이전트가 `CLAUDE.md`를 자동으로 읽고 루프를 따른다.

> 멀티에이전트를 쓰지 않는 단순 프로젝트면 4번은 나중에 채워도 된다.

## 2) 매 작업 하는 법
하고 싶은 말 + "prd.template로 PRD부터, 코드 전에 계획 보여줘".
Claude Code면 슬래시 명령으로 줄일 수 있다:
- `/feature 발표자 노트 추가`
- `/bugfix 로그인하면 빈 화면 뜸`
- `/spec 막연한 요청 명세화`
- `/validate`: 완료 전 의미 검증 (골든셋 G1~G3)
- `/verify`: 기술 검증 (verify.sh)
- `/handoff`: 세션 인수인계 문서 생성
- `/escalate [이유]`: 작업 중단 + 에스컬레이션

흐름: PRD(주문서) → [승인 게이트: 네 OK] → 실행 → `./verify.sh` + `/validate` → 정직한 보고.
오타·문구 같은 사소한 일은 PRD 없이 바로 시켜도 된다(경량은 가볍게).

## 3) 도구별 차이
- **Claude Code(터미널)**: `CLAUDE.md`/`AGENTS.md` 자동 로드, `@import`, `/memory`,
  PreToolUse 가드(.claude/), 슬래시 명령 전부 작동.
- **Antigravity 대화창**: `CLAUDE.md`를 "Always On 규칙"으로 등록해 사용.
  PreToolUse 가드·슬래시 명령은 미지원(verify.sh·CI로 대체).

## 4) 게이트를 단계로 올리기
- 지금: `./verify.sh` 로컬 검증 + `/validate` 골든셋 + 행동 규율(권고).
- 다음: `.github/workflows/verify.yml`을 켜서 CI 필수체크(머지 차단)로.
- Claude Code면 `.claude/`의 가드 훅으로 위험명령 자동 차단.
- 전부 "필요해질 때" 올린다. 미리 다 켜지 않아도 된다.

## 5) 기존 다른 레포에 이식하려면
`docs/ops/apply-loop.prompt.md`의 프롬프트 블록을 그 레포의 에이전트에게 주면,
조사 → 계획 → (승인) → 적용 순으로 이 체제를 얹어준다.

## 6) 막연한 목표를 막는 "명세 인터뷰" (이 템플릿의 핵심 장치)
"AI 학습 사이트 만들고 싶어" 같은 막연한 한 줄을 주면, 에이전트는 바로 코드를 짜지 않고
소크라테스식으로 한 번에 하나씩 캐물어 명세를 빚는다(`docs/ops/spec-interview.md`).
- 새 프로젝트(빈 폴더): `/init-project AI 학습 사이트` → 제품 수준 인터뷰 → docs/specs/PRD.md
- 기존 프로젝트에 기능: `/spec 발표자 노트 추가` → 작업 수준 인터뷰 → docs/plans/PLAN-*.md
- 슬래시 명령 없이도: "이거 만들고 싶은데 막연해. spec-interview 절차대로 캐물어줘." 한 줄이면 동작.
- 인터뷰 첫 질문은 **"이거 왜 만들어요?"**(§0 동기: 수익/업무효율/학습/취미/남의요청). 답에 따라 완성 기준·검증 강도가 조절된다: 취미면 가볍게, 사업이면 빡세게.
- 스택이 막막하면 `STACK-OPTIONS.md`(잘 알려진 스택·에셋 참고 카탈로그, 강요 아님)를 보면 된다.

## 6-1) "매번 엔터" 줄이기 + 위험 명령 차단 (권한)
`.claude/settings.json`이 명령을 3단계(자동/확인/차단)로 나눈다. "삭제 거부"가 뜨면 안전장치가 작동한 것: 분류 기준·조절법은 `.claude/PERMISSIONS.md` 하나만 보면 된다.

## 6-2) 검증은 "일 안 한 눈"이 본다 (검증자 서브에이전트)
구현이 끝나면, 가능하면 분리된 검증자가 채점한다: `"verifier 서브에이전트로 이 작업을 PRD 대비 검증해줘"`. 신선한 컨텍스트가 파일(PRD·PLAN)만 기준으로 판정하므로, 구현 중의 오해가 채점에 묻지 않는다. 고위험(돈·인증·삭제·배포) 작업엔 필수, 가벼운 작업엔 생략해도 된다.

## 7) 퀄리티 게이트 · HITL · 에스컬레이션 (신규)
이미지의 14·15·16번 개념이 이 템플릿에 통합되었다:

**퀄리티 게이트 3단계**: verify.sh + /validate 이후 에이전트는 **통과 / 보류 / 재시도** 중 하나만 보고한다.
임의로 "됐다"고 선언하는 pass/fail 이분법이 아니다.

**HITL 자동 중단**: 재시도 3회 초과·비용 상한·성공 기준 충돌·보안 판단 필요 시
에이전트가 스스로 멈추고 "HITL 요청"을 보고한다. 억지로 진행하지 않는다.

**에스컬레이션**: `/escalate [이유]`로 실행. PLAN을 Blocked로 전환하고 지정 경로에 알림.
`docs/ops/multi-agent.md §5`의 에스컬레이션 경로가 채워져 있어야 작동한다.

## 8) 멀티에이전트로 확장할 때
단일 에이전트로 시작하고, 아래 신호가 보일 때 멀티에이전트로 전환한다:
- 작업이 "기획 따로 / 실행 따로 / 검토 따로" 구분되기 시작
- 두 에이전트가 같은 파일을 동시에 수정하는 충돌 발생
- 검토를 실행한 에이전트가 직접 하면 이해충돌 우려

전환 방법: `docs/ops/multi-agent.md §1` 역할 분리표대로 역할을 지정하고 시작.

## 9) 크로스툴(Antigravity·Cursor)에서 쓰려면
이 템플릿은 Claude Code 기준 `CLAUDE.md`가 진입점이다. 다른 도구는:
- Antigravity: `CLAUDE.md` 내용을 Rules에 **Always On**으로 등록(또는 `cp CLAUDE.md AGENTS.md`).
- Cursor: `cp CLAUDE.md AGENTS.md` (AGENTS.md를 읽음).
※ Claude Code는 CLAUDE.md와 AGENTS.md를 *둘 다* 자동으로 읽으니, **한쪽만 두기**(둘 다 두면 중복 로딩).

## 10) 이 템플릿에 들어있는 원칙 문서
- `CLAUDE.md`: 자동 로드 진입점. 모든 ops 문서를 import.
- `docs/ops/agent-loop.md`: 루프 5단계 + MUST 행동 규율.
- `docs/ops/guardrails.md`: 기술·UI·보안(웹 OWASP + AI/LLM OWASP)·HITL·퀄리티 게이트.
- `docs/ops/multi-agent.md`: 역할 분리 · 퀄리티 게이트 3단계 · HITL 트리거 · 에스컬레이션.
- `docs/ops/golden-set.md`: 의미 검증 질문 세트 (/validate 실행).
- `docs/ops/memory-context.md`: 세션 간 연속성 · ADR 재사용 · 인수인계.
- `docs/specs/decisions/ADR-000-collaboration-principles.md`: 인간=목표·결정 / AI=실행+정직 보고.
- `docs/plans/BACKLOG-deferred.md`: 지금 미룬 것 + 언제 켤지 신호.

## 11) 코드 품질 + 운영 사이클 (v2.3)
**A1: verify.sh 레시피**: `docs/ops/kit/recipes/`에 스택별(웹·Python·GAS·정적웹) 시작점이 있다.
빈 verify.sh를 채울 때 복붙 출발점으로 쓰되, **반드시 당신 프로젝트의 실제 명령으로 교체**한다.
(명령 버전은 시간이 지나면 바뀐다: 박제하지 말 것.)

**B1: 운영 런북 (opt-in)**: 평소엔 없다. 실서비스에 들어갈 때 `/ops-init`로 켠다.
켜면 `docs/ops/ops-runbook.md`가 생기고, 장애 시 `/incident`로 대응 절차에 진입한다.
토이·슬라이드·사내 스크립트엔 안 켜도 된다(안 켜면 아무 강제 없음).

**B2: 버그 재발 방지**: 버그 수정(`/bugfix`) 마무리 때 골든셋 G12가 "재발 방지 테스트 넣었나"를 묻는다.
**권장이지 강제가 아니다**: 빠른 깊이·오타성 수정·프로토타입은 면제. 테스트 인프라 없으면 BACKLOG 기록으로 갈음.

→ 이 셋으로 "개발 → 마무리 → 운영 → 버그 → 재발방지 → 다시 개발" 순환이 닫힌다.
