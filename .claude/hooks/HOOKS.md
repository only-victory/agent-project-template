# 훅 안내서 (HOOKS)

> 훅 = "지침이 아니라 기계"다. 문서의 [MUST]는 AI가 어길 수 있지만, 훅은 결정적으로 작동한다.
> 이 템플릿의 훅 5종: **기본 켜짐 3종 + 기본 꺼짐 2종**(강력하지만 실사용 검증 후 켜는 것 권장).

## 기본 켜짐 (settings.json에 등록됨)

| 훅 | 시점 | 역할 |
|----|------|------|
| `guard.sh` | PreToolUse(Bash) | 위험 명령(rm -rf 등)·비밀 유출 패턴 차단 |
| `session-start.sh` | SessionStart | 세션 시작 시 로드맵 위치·진행 중 PLAN·인수인계를 컨텍스트에 자동 주입 (위치 복원의 기계화) |
| `plan-date-check.sh` | PostToolUse(Edit·Write) | PLAN/PRD 수정 후 "최종 수정" 날짜 미갱신이면 알림 (doc-sync 센서) |

## 기본 꺼짐 (만들어져 있음: 필요하면 켠다)

### stop-verify-gate.sh (Stop 훅): "검증 없이 마무리" 차단
- In Progress 작업이 있는데 검증 흔적(verify.sh가 남기는 `.claude/.last-verify`)이 없거나, 검증 이후 또 코드가 수정됐으면: **응답 종료 자체를 차단**하고 검증을 요구한다.
- 가장 강력한 훅이라 기본 꺼짐. 며칠 실사용으로 다른 훅에 익숙해진 뒤 켜는 걸 권장.
- 무한 차단 방지 내장(stop_hook_active 시 통과). docs만 수정한 세션은 면제.

### session-metrics.sh (SessionEnd 훅): 토큰 실측 자동 기록
- 세션이 끝날 때 트랜스크립트에서 토큰 사용량을 파싱해 `docs/plans/MEASUREMENTS.md`에 자동 기록. /cost를 매번 안 쳐도 측정이 쌓인다.
- 주의: 트랜스크립트는 내부 포맷이라 도구 업데이트로 파싱이 깨질 수 있음: 깨지면 그 세션 줄만 안 남고 조용히 통과(세션에 해 없음).

### 켜는 법
`.claude/settings.json`의 `"hooks"` 객체에 아래를 추가:
```json
"Stop": [
  { "hooks": [ { "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/stop-verify-gate.sh\"" } ] }
],
"SessionEnd": [
  { "hooks": [ { "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/session-metrics.sh\"" } ] }
]
```
- 하나만 켜도 된다(문제 격리를 위해 하나씩 켜고 며칠 써보는 걸 권장).
- 끄는 법: 해당 블록을 지우면 끝. 스크립트 파일은 그대로 둬도 무해.

## 문제가 생기면
- 세션이 안 끝나거나 이상하면: 마지막에 켠 훅을 의심하고 그 블록을 제거 → 재현 확인.
- 훅은 전부 Claude Code 전용. 다른 도구(Cursor 등)에선 문서 지침이 폴백이다.
