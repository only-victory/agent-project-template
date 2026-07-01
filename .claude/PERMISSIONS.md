# 권한 설정 가이드 (settings.json permissions)

> **파일명 유래**: Claude Code의 `permissions`(권한) 설정을 설명한다. "매번 엔터 눌러 허락하기"의 피로를 줄이되, 위험한 건 여전히 막기 위한 분류.

## 왜 있나
Claude Code는 기본적으로 bash 명령마다 사용자 승인을 받는다. 안전하지만, `ls`·`cat`·`git status` 같은 무해한 것까지 매번 물어 피곤하다. 그래서 **안전한 건 자동(allow), 상태 바꾸는 건 확인(ask), 위험한 건 차단(deny)** 으로 나눈다.

## 기본값은 "스택 무관 보편 명령"만
이 템플릿의 settings.json 기본값에는 **언어·도구에 독립적인 명령만** 들어있다(읽기·조회·검사 + git 기본 + rm·sudo 차단). 특정 스택 도구(npm·python·clasp·vercel·aws 등)는 **일부러 넣지 않았다** ─ 인프라 미정 원칙. 프로젝트마다 스택이 다르기 때문이다.

## 스택이 정해지면 추가한다 (인터뷰/사전 확인 → 반영)
명세 인터뷰나 사전 확인에서 **그 프로젝트의 스택·도구가 정해지면**, 아래 동사 기준으로 해당 도구 명령을 settings.json에 추가한다. (AI가 인터뷰에서 스택을 알게 되면 이 추가를 제안할 수 있다.)

### 분류 기준 (동사로 판단 ─ 스택 무관 보편 규칙)
| 동사 패턴 | 처리 | 왜 |
|-----------|------|----|
| 조회·검사: list·get·status·diff·log·show·describe·ps | **allow (자동)** | 아무것도 비가역으로 바꾸지 않음 |
| 빌드·테스트: build·test·lint·검증 스크립트 | **allow (자동)** | 프로젝트 안에서만 돎. 결과를 비가역으로 바꾸지 않음 |
| 상태 변경: add·commit·install·실행(run)·mv·cp | **ask (확인)** | 상태를 바꿈. .env 커밋 같은 사고 가능 → 한 번 묻는다 |
| 원격·배포: push(원격)·deploy·publish·--prod | **ask 또는 deny** | 외부 영향. 프로덕션이면 deny |
| 비가역·삭제: rm·delete·terminate·remove·prune·--force·reset --hard·드롭 | **deny (차단)** | 되돌릴 수 없음. 자동은 물론 확인도 위험 |

### 스택별 추가 예시 (이건 예시일 뿐, 그대로 박지 말 것)
- Node 프로젝트라면: `npm test`·`npm run build`·`npm run lint`는 allow, `npm install`·`npm run*`은 ask, 배포 스크립트는 deny.
- Python이라면: `pytest`는 allow, `python <script>`·`pip install`은 ask.
- 배포 CLI(예: 호스팅 도구)라면: 조회는 allow, `deploy`·`--prod`는 deny.
- 클라우드 CLI라면: `describe`·`list`·`get`은 allow, `delete`·`terminate`는 deny.
> 위는 **예시**다. 실제 추가는 그 프로젝트가 쓰는 도구에 동사 기준을 적용해서 한다.

## 보수적 설계 원칙 (중요)
- **의심스러우면 allow가 아니라 ask로.** allow는 "아무것도 안 바꾸는" 명령만.
- **deny는 넉넉하게.** 빠진 위험 패턴이 있으면 추가한다.
- **와일드카드(`*`)는 넓다.** `npm run*`을 allow하면 `npm run deploy`도 통과하므로, 통째로 열지 말고 `npm run build/test/lint`만 명시한다.
- **2차 안전망**: 설령 allow에 위험한 게 새어도, `hooks/guard.sh`(PreToolUse, exit 2)가 `rm -rf`·force push 등을 권한과 무관하게 한 번 더 차단한다. 단 guard.sh가 모든 위험을 아는 건 아니므로 이 분류도 보수적으로 유지한다.

## 조정하는 법 (좁게 시작 → 넓히기)
- 처음엔 좁게(기본 보편 명령만) 쓰다가, "이건 매번 물어서 진짜 귀찮다" 싶은 안전한 명령만 하나씩 allow로 옮긴다.
- 한 번에 넓게 열고 줄이는 것보다, 좁게 열고 넓히는 게 안전하다.

## 주의 (절대 금지)
- `claude --dangerously-skip-permissions` (권한 전체 끄기)는 쓰지 않는다. AI가 `rm -rf`도 멋대로 실행할 수 있어 이 템플릿의 "비가역은 확인" 철학과 정면 충돌한다.
