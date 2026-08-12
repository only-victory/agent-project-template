# kit: 보편 강제 스캐폴딩 (정책을 "실행되는 게이트"로)

`agent-loop`/`harness`가 *말*이라면 이 kit은 *게이트*다. 핵심은 단 하나의 보편 진입점.

- **verify.sh**: 이 레포의 "통과" 정의(스택 무관). 에이전트·CI·사람이 *같은 한 줄*을 호출.
- **hooks/guard.sh + settings.json**: 위험·비가역 명령 차단(PreToolUse, exit 2). *[Claude Code 어댑터]*
- **ci.example.yml**: (1)미완성 바인딩 차단 (2)verify 실행. *[GitHub Actions 어댑터: 교체 가능]*

## 설치
1. `verify.sh` → 루트, 실제 검사 명령으로 채움, `chmod +x verify.sh`.
2. `hooks/guard.sh` → `.claude/hooks/guard.sh` · `settings.json` → `.claude/settings.json` (둘 다 커밋).
3. `ci.example.yml` → `.github/workflows/verify.yml` (또는 쓰는 CI로 이식).
4. `CLAUDE.md` §2를 **"통과 = `./verify.sh` exit 0"** 한 줄로 단순화.

## 왜 보편적인가
스택이 바뀌어도 게이트는 안 바뀐다: 바뀌는 건 `verify.sh` 안의 명령뿐.
훅/CI는 얇은 어댑터라 도구·플랫폼에 맞게 갈아끼운다. 강도 설계 근거 = `harness-design.md`.
