# agent-project-template

> AI 에이전트(Claude Code 등)와 안전하게 협업하기 위한 프로젝트 스캐폴드.
> 막연한 아이디어를 인터뷰로 명세화하고, 검증 게이트로 "예쁜 쓰레기"를 막고,
> 개발 → 마무리 → 운영까지 라이프사이클을 닫는다.
> **단일 자동화부터 멀티에이전트·실서비스까지** 범용. 스택 무관(Node·Python·GAS·정적웹 등).

---

## 사전 준비물

> **이 템플릿은 macOS / Linux 환경 기준입니다.** 검증·보호 스크립트(`verify.sh`·`guard.sh`·`*gate.sh`)가 셸 스크립트(`sh`)로 되어 있기 때문입니다. **Windows 사용자는 아래 "환경별 사용"의 사전 준비가 필요합니다.**

### 환경별 사용 (먼저 확인)

| 환경 | 준비 | 비고 |
|------|------|------|
| **macOS / Linux** | 추가 준비 없음 | 그대로 사용. `sh`·`git`이 기본 내장 |
| **Windows** | **WSL 또는 Git Bash 필수** | 아래 참고 |

**Windows 사용자 필수 준비** (둘 중 하나):
- **WSL (권장)**: Windows Subsystem for Linux. PowerShell에서 `wsl --install` 후 WSL 터미널에서 Claude Code를 실행한다. macOS와 동일하게 100% 작동한다.
- **Git Bash**: [git-scm.com](https://git-scm.com) 설치 시 함께 오는 Bash. 이 위에서 실행하면 `sh` 스크립트가 작동한다.

> **왜 필요한가**: 방법론 문서·슬래시 명령(`/spec` 등)·권한 설정(`settings.json`)은 OS 무관하게 작동한다. 하지만 검증 게이트와 위험 명령 차단 훅(`guard.sh`, 2차 안전망)은 `sh`가 있어야 돈다. **PowerShell·CMD 단독으로는 이 스크립트들이 동작하지 않아 안전망이 빠진다.**
>
> IDE(Antigravity·VS Code 등)에서 쓸 때는 **IDE 내장 터미널이 WSL 또는 Git Bash를 가리키도록** 설정한 뒤 Claude Code를 실행하면 된다.

### 가져오기(다운로드)만 할 때: **Node.js 하나면 끝**
이 템플릿을 내 폴더로 받아오는 데 필요한 건 Node.js뿐이다. (`npx degit`이 Node에 포함된 `npx`를 쓴다.)
```bash
node -v          # 버전 숫자가 나오면 준비 완료
```
없으면: [nodejs.org](https://nodejs.org)에서 설치하거나, 맥이면 `brew install node`.
> install.sh(curl) 방식도 curl은 맥·리눅스 기본 내장이라 사실상 Node.js만 있으면 된다. (Windows는 WSL/Git Bash 안에서)

### 개발·검증까지 할 때 (가져온 뒤, 필요해지면)
> 자세한 점검 명령은 `PREREQUISITES.md` 참고.
가져오는 단계엔 필요 없고, 실제 작업할 때 쓰는 것들:
- **Claude Code**: 슬래시 명령(`/spec` 등) 실행 (`claude --version`)
- **Python 3**: 게이트 스크립트(spec-gate·golden-gate)가 사용 (`python3 --version`)
- **Git**: 버전 관리·푸시 (`git --version`)
- **셸 환경**: macOS/Linux는 기본. **Windows는 WSL 또는 Git Bash** (위 "환경별 사용" 참고)
- **스택별 도구**: 프로젝트 종류에 따라 그때 설치 (예: GAS면 clasp, Python이면 pytest 등)

---

## 빠른 시작: 공개 창고에서 가져오기

이 레포는 **원본 창고**다. 새 프로젝트를 시작할 때마다 여기서 **파일만** 가져와 설치한다.
(`.git`은 따라오지 않으므로, 새 프로젝트는 자기만의 git 이력을 갖는다 (창고와 분리).)

### 방법 1: degit 한 줄 (추천, 가장 깔끔)
프로젝트 폴더를 열고 터미널에서 (그 폴더 루트에 바로 풀린다):
```bash
npx degit only-victory/agent-project-template .
```
마지막 `.`이 "지금 이 폴더에 바로 풀어라"는 뜻이다. 하위 폴더가 더 생기지 않는다.

> `degit`은 깃허브에서 `.git` 없이 파일만 받아온다. 가장 빠르고 깨끗하다.

### 방법 2: install.sh 한 줄
프로젝트 폴더를 열고 터미널에서:
```bash
curl -fsSL https://raw.githubusercontent.com/only-victory/agent-project-template/main/install.sh | sh
```
degit이 있으면 그걸 쓰고, 없으면 git clone으로 폴백한다. 설치 후 안내 메시지까지 출력.

### 방법 3: Claude Code에게 시키기
터미널에서 `claude` 접속 후, 빈 프로젝트 폴더에서:
```
이 폴더에 https://github.com/only-victory/agent-project-template 의 파일을
degit으로 가져와서 설치해줘. 그다음 setup-check.sh를 돌려서 채울 빈칸을 알려줘.
```

### 방법 4: 이미 개발 중인 폴더에 얹기
```bash
npx degit only-victory/agent-project-template /tmp/apt
cp -r /tmp/apt/.claude /tmp/apt/docs /tmp/apt/CLAUDE.md /tmp/apt/verify.sh /tmp/apt/setup-check.sh .
```
그다음 Claude Code에게 `docs/ops/apply-loop.prompt.md` 지시대로 레포에 접목해 달라고 한다.

> 깃허브 아이디(only-victory)가 이미 반영되어 있다. 다른 계정으로 쓰려면 이 값만 바꾸면 된다.

---

## 설치 직후 (필수 1회)

```bash
# 1) 빈칸 점검: 무엇을 채워야 하는지 보여준다
sh setup-check.sh

# 2) 터미널에서 Claude Code 접속
claude

# 3) 로드 확인 후 첫 작업
#    /memory 로 CLAUDE.md 로드 확인 → /init-project 또는 /spec
```

채워야 할 핵심: `CLAUDE.md`의 `<PROJECT_NAME>`·위험작업, `verify.sh`의 실제 검사 명령.
(verify.sh는 `docs/ops/kit/recipes/`에 스택별 시작점이 있다: 복붙 후 교체.)

---

## 명령어 (Claude Code 슬래시 명령)

> 터미널에서 `claude`로 접속한 환경에서 작동한다. 각 명령은 "자주 쓰는 지시"의 단축어일 뿐이라,
> 명령 없이 평소 말로 시켜도 `CLAUDE.md`가 자동 로드돼 같은 루프를 따른다.

> **명령어를 외울 필요 없다.** 아래는 빠른 단축어일 뿐, 평소 말로 해도("버그 고치고 싶어", "어디까지 했지?") 맞는 흐름으로 연결된다. 모호하면 AI가 되묻고, 위험한 작업은 확인 후 실행한다.

| 단계 | 명령 | 하는 일 |
|------|------|---------|
| **시작** | `/init-project [설명]` | 빈 폴더에서 새 제품 시작: 11축 인터뷰(깊게) → `docs/specs/PRD.md` |
| | `/spec [설명]` | 막연한 요구를 명세로: 깊이 선택 인터뷰 → `docs/plans/PLAN-*.md` |
| **개발** | `/feature [설명]` | 기능 추가: PRD부터, 계획 승인 후 실행 |
| | `/bugfix [설명]` | 버그 수정: 추측 금지, 원인규명부터. 마무리 때 재발방지 확인 |
| **검증** | `/verify` | 기술 검증: `./verify.sh` 실행, 실패 시 원인규명 복귀 |
| | `/validate` | 의미 검증: 골든셋(진짜 목표 달성?) → 통과/보류/재시도 |
| **막힘** | `/escalate [이유]` | 작업 중단: PLAN을 Blocked로, 에스컬레이션 경로로 알림 |
| | `/handoff` | 세션 인수인계 문서 생성 |
| **재개** | `/resume` | 멈췄다 돌아왔을 때 현재 위치·다음 진입점 브리핑 (로드맵 기반) |
| **회고** | `/retro` | 구간 회고: 반복 마찰을 카운트해 임계치 넘으면 개선·v3 신호로 격상 |
| **운영** | `/ops-init` | (opt-in) 운영 런북 활성화: 실서비스 진입 시 1회 |
| | `/incident [증상]` | 장애 대응: 범위파악 → 완화 → 원인규명 → 수정 |

> Antigravity *대화창*(채팅 UI)에서는 슬래시 명령이 안 먹는다. 그 경우 명령 파일 내용을 풀어서 말하면 된다.
> (터미널 + Claude Code 환경이면 그대로 작동.)

---

## 구성

```
CLAUDE.md                      ← 에이전트 자동 로드 진입점 (ops 문서 10개 import)
GETTING-STARTED.md             ← 입문 가이드 (이 파일부터)
PREREQUISITES.md               ← 사전 준비물 (OS별·단계별, Windows는 WSL/Git Bash)
STACK-OPTIONS.md               ← 스택·에셋 선택 참고 카탈로그 (정보 제공용, 강요 아님)
PUBLISH.md                     ← 공개 창고에 배포하는 법 (관리자용)
setup-check.sh                 ← 설치 직후 빈칸 점검
install.sh                     ← 한 줄 설치 스크립트
verify.sh                      ← 기술 검증 진입점 (채워서 쓸 것)
src/                           ← 실제 코드 자리

docs/ops/                      ← 행동·운영 규율 (에이전트가 따르는 규칙)
  agent-loop.md                · 루프 5단계 (정렬→결정→실행→검증→보고), 완료 계약·막힘 조건
  spec-interview.md            · 막연한 목표 → §0 동기 + 11축 명세 인터뷰 (깊이 선택)
  guardrails.md                · 기술·보안·HITL·퀄리티 게이트 원칙
  multi-agent.md               · 두 형태 구분(한 세션 vs 여러 세션)·경로 분리·HITL·에스컬레이션
  golden-set.md                · 의미 검증 질문 (/validate), 검증 라우팅·배포 함정(G13)
  memory-context.md            · 세션 연속성·ADR 재사용·인수인계·INDEX·멀티 디바이스·세션 길이
  roadmap.md                   · 로드맵(opt-in): 큰 프로젝트 단계 추적·재개·미정[?] 처리
  decision-support.md          · 결정·기획 보조: 떠넘기지 않고 고르기 쉽게(트레이드오프·추천·범위 좁히기)
  retro.md                     · 회고: 반복 마찰을 카운트→임계치 넘으면 개선·v3 신호로
  intent-routing.md            · 자연어 의도 연결: 명령어 몰라도 평소 말로(모호·위험하면 확인)
  harness-design.md            · 강제 게이트 설계 근거 (권한=1차 게이트, guard.sh=2차망)
  doc-sync.md                  · 코드↔문서 동기화 (PLAN 날짜·INDEX 갱신 포함)
  apply-loop.prompt.md         · 기존 레포에 이 체제 접목하는 프롬프트
  kit/                         ← 복붙 가능한 게이트 구현체
    verify.sh · spec-gate.sh · golden-gate.sh · escalation-gate.sh
    recipes/                   · 스택별 verify.sh 시작점 (Node·Python·GAS·정적웹+혼용)
    hooks/guard.sh             · 위험명령 차단 (PreToolUse)
  templates/
    ops-runbook.template.md    · 운영 런북 씨앗 (/ops-init 으로 활성화)

docs/specs/                    ← 제품 명세
  PRD.md · decisions/ (ADR)
docs/plans/                    ← 작업 명세·이력
  prd.template.md              · PRD/PLAN 서식 (동기 필드·생성/수정 날짜 헤더)
  INDEX.md                     · 전체 PLAN 한눈에 (상태·날짜), 100개+ 관리
  archive/                     · 완료(Done)되고 참조 끝난 PLAN 보관
  CHANGELOG.md · BACKLOG-deferred.md

.claude/
  commands/                    ← 슬래시 명령 12개 (위 표)
  PERMISSIONS.md               · 권한 분류 가이드 (동사로 판단, 좁게 시작→넓히기)
  hooks/guard.sh · settings.json (allow/ask/deny 권한 + guard 훅)
.github/workflows/verify.yml   ← CI 게이트 (spec·golden·escalation·verify)
```

---

## 핵심 원칙

- **인간 = 목표·계획·결정 / AI = 실행 + 정직한 보고** (ADR-000)
- **이중 검증**: `verify.sh`(기술) + `/validate`(의미·골든셋)
- **3단계 게이트**: 통과 / 보류 / 재시도 (pass/fail 이분법 금지)
- **자동 중단**: HITL 트리거(재시도 3회·비용상한·보안판단) → 사람에게
- **검증 없으면 예쁜 쓰레기**

---

## 정직한 한계 (가짜 안전감 방지)

이 템플릿은 **"프로세스 완성도"를 올린다. "코드 품질 그 자체"를 보장하진 않는다.**

- **게이트는 당신이 채운 만큼만 강하다.** 빈 `verify.sh`는 의도적으로 실패하지만,
  부실한 verify.sh(예: `echo ok`)는 통과시킨다. 실제 검사를 채우는 건 당신 몫.
- **점수·판정은 에이전트 자기평가다.** 골든셋 "충실/부분" 판정도, 완성도 %도
  에이전트가 스스로 매긴다 → 후하게 줄 수 있다. 리포트는 사람이 한 번 확인하라.
- **아키텍처·보안·확장성의 깊은 판단은 안 해준다.** 템플릿은 "물어봐라"고 시키지만
  *좋은 답*을 보장하진 않는다. 특히 돈·인증·개인정보가 들어가는 서비스는
  실제 전문성이 반드시 더해져야 한다.

즉 이건 **좋은 출발점이자 규율**이지, "완벽한 결과를 찍어내는 기계"가 아니다.

---

## 버전 히스토리

최근 주요 변경 (전체는 [CHANGELOG.md](./CHANGELOG.md) 참고):

- **v2.29**: 공개 유출 방지: git 커밋/푸시 시 비밀 패턴 경고(guard.sh) + 공개 전 점검(G14)
- **v2.28**: STACK-OPTIONS.md 참고 카탈로그: 잘 알려진 스택 선택지 정보 제공(강요 아님) + 검증 필터로 갱신
- **v2.27**: 인터뷰 §0 '동기' 축: 왜 만드나(수익/업무/학습/취미/요청)로 완성기준·성공지표·수명·검증강도 조율
- **v2.26**: 범용화 패스: 권한 기본값에서 특정 스택 제거(보편 명령만) + 인터뷰가 스택·환경 알면 반영 + 세션 길이 관리(/compact) + 환경별 사용(Windows WSL)
- **v2.25**: 멀티 디바이스 핸드오프: 여러 환경을 commit/push↔pull로 오가며 이어 작업
- **v2.24**: 권한 기본값(settings.json): 안전=자동·상태변경=확인·위험=차단(보수적) + guard.sh 2차망
- **v2.23**: PLAN 인덱스(INDEX.md)로 100개+ 한눈에 + 완료분 archive 보관
- **v2.22**: PLAN/PRD 생성·최종수정 날짜 메타 헤더(파일명 안 바꿔 git·링크 보존)
- **v2.21**: 배포 함정 '로컬≠커밋' git status/show 점검(미커밋 의존성으로 CI 빌드 깨짐 방지)
- **v2.20**: 멀티에이전트 두 형태 구분(한 세션 오케스트레이션 vs 여러 세션) + 동시 작업 충돌 방지
- **v2.19**: 완료 계약(Goal Contract): done/blocked/uncertain으로 끝없이 돌거나 애매하게 닫힘 방지
- **v2.18**: AI·외부 생성 데이터 검증(출력 신뢰 금지, 받는 즉시 구조 검증)
- **v2.17**: 컴포넌트 연결 검증(A출력=B입력) + em-dash 사전 방지
- **v2.16**: 외부 리뷰 선별 반영(가드 인터셉터 강화·로드맵 복구 우선)
- **v2.15**: UI/UX 감성·차별화 축 + 입문자 스택 추천
- **v2.14**: 자연어 의도 연결(명령어 안 외워도 됨) + 비가역 Echo-back 확인
- **v2.13**: 검증 라우팅(작업 유형별 골든셋) + 회고(반복 마찰 카운트→격상)
- **v2.12**: 결정 보조(트레이드오프·가역성·추천으로 사람 결정 도움)
- **v2.11**: 로드맵 안전장치(opt-in): 단계 추적·세션 재개(/resume)·이탈 감지·미정[?] 처리
- **v2.10**: 상업 리스크 흡수(비용·법규·전환) + 입문자 배려(용어 풀이·모름 안내)
- **v2.9**: 다역할 서비스 지원 (역할별 기능·사용자 여정·화면 구체성)
- **v2.8**: 인터뷰 질문을 선택형(번호+화살표)으로, 조기 개발 방지, 진행 표시·되돌리기
- **v2.7**: "서늘한 질문" + 가치·검증 축 (누가 왜 값을 치르나)
- **v2.6**: 사전 준비물 문서, 표기 정리
- **v2.5**: 공개 창고 모델 (degit 한 줄 설치)
- **v2.3**: verify.sh 스택별 레시피 + 운영 런북(opt-in)
- **v2.2**: 인터뷰 6축 → 11축, 깊이 선택
- **v2.0~2.1**: 멀티에이전트·HITL·골든셋 의미 검증 게이트
- **v1.0**: 최초 릴리스 (루프·인터뷰·가드레일·게이트)

---

## 라이선스
<원하는 라이선스: 예: MIT. 미정이면 비워둬도 됨>
