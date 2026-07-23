#!/usr/bin/env sh
# PreToolUse(Bash) 가드: 위험·비가역 명령을 모델 판단과 무관하게 차단(인터셉터).
# 차단은 exit 2 만 유효(exit 1은 경고일 뿐 통과됨). 빠르게(<500ms). 외부 의존 없음.
# 등록: .claude/settings.json (동봉).
# 설계: jq로 필드 파싱하지 않고 stdin 원본을 그대로 스캔 → 의존성·파싱실패로 인한
#       fail-open(가짜 안전감)을 제거. 파괴적 패턴엔 오탐보다 과차단이 안전하다.
# 동작: 위험 명령을 "실행 직전에" 가로채 멈춘다. AI는 이 명령을 그냥 통과시킬 수 없고,
#       사람에게 계획을 설명하고 명시적 승인을 받은 뒤에만 진행한다(HITL 강제).
payload=$(cat)
[ -z "$payload" ] && exit 0

# 보편 위험 패턴(셸 수준: 스택 무관). 아래에 프로젝트 비가역/외부영향 명령을 추가.
deny='rm -rf (/|~|\$HOME|\.\.)|git push [^|]*(--force|-f)|mkfs|dd if=|drop +table|truncate +table'
# 추가 예) |terraform apply|kubectl [^|]*delete|aws s3 rm|deploy [^|]*prod

if printf '%s' "$payload" | grep -Eiq "$deny"; then
  printf '====================================================\n' >&2
  printf '[차단] 위험·비가역 명령으로 판단되어 실행을 멈췄습니다.\n' >&2
  printf '이 명령은 되돌릴 수 없습니다. agent-loop 비협상 규칙:\n' >&2
  printf '  1) AI는 무엇을·왜 하려는지 계획을 사람에게 설명한다\n' >&2
  printf '  2) 사람이 명시적으로 승인한다\n' >&2
  printf '  3) 그 뒤에만 진행한다\n' >&2
  printf '실행하려면: 사람이 직접 명령을 입력하거나 승인 의사를 밝히세요.\n' >&2
  printf '====================================================\n' >&2
  exit 2
fi

# --- 공개 유출 방지: git add/commit/push에 민감정보가 섞였는지 경고 ---
# 차단(exit 2)이 아니라 경고(exit 2로 멈추되 사람이 확인). 오탐 가능성이 있어
# "무조건 막기"보다 "사람이 한 번 확인"하게 한다. 진짜 비밀이면 커밋에서 빼고,
# 오탐이면 사람이 다시 명령한다. security through obscurity가 아니라 실수 방지용.
case "$payload" in
  *"git add"*|*"git commit"*|*"git push"*)
    secret='(sk-[A-Za-z0-9]{16,}|api[_-]?key|secret[_-]?key|-----BEGIN [A-Z ]*PRIVATE KEY|password\s*=|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9A-Za-z-]+)'
    if printf '%s' "$payload" | grep -Eiq "$secret"; then
      printf '====================================================\n' >&2
      printf '[확인 필요] 커밋/푸시 명령에 민감정보로 보이는 패턴이 있습니다.\n' >&2
      printf '(API 키·비밀번호·프라이빗 키 등) 공개 레포면 유출될 수 있습니다.\n' >&2
      printf '  1) 진짜 비밀이면: 커밋에서 빼고 .gitignore/환경변수로 옮기세요\n' >&2
      printf '  2) 오탐이면: 사람이 확인 후 다시 명령하세요\n' >&2
      printf '  (참고: 커밋 전 git diff --staged 로 무엇이 올라가는지 확인)\n' >&2
      printf '====================================================\n' >&2
      exit 2
    fi
    ;;
esac


exit 0
