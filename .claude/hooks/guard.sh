#!/usr/bin/env sh
# PreToolUse(Bash) 가드: 위험·비가역 명령을 모델 판단과 무관하게 차단.
# 차단은 exit 2 만 유효(exit 1은 경고일 뿐 통과됨). 빠르게(<500ms). 외부 의존 없음.
# 등록: .claude/settings.json (동봉).
# 설계: jq로 필드 파싱하지 않고 stdin 원본을 그대로 스캔 → 의존성·파싱실패로 인한
#       fail-open(가짜 안전감)을 제거. 파괴적 패턴엔 오탐보다 과차단이 안전하다.
payload=$(cat)
[ -z "$payload" ] && exit 0

# 보편 위험 패턴(셸 수준: 스택 무관). 아래에 프로젝트 비가역/외부영향 명령을 추가.
deny='rm -rf (/|~|\$HOME|\.\.)|git push [^|]*(--force|-f)|mkfs|dd if=|drop +table|truncate +table'
# 추가 예) |terraform apply|kubectl [^|]*delete|aws s3 rm|deploy [^|]*prod

if printf '%s' "$payload" | grep -Eiq "$deny"; then
  printf '차단: 위험·비가역 명령으로 판단됨. agent-loop 비협상: 계획→사용자 승인 후 진행하세요.\n' >&2
  exit 2
fi

# --- 공개 유출 방지: git add/commit/push에 민감정보가 섞였는지 확인 ---
case "$payload" in
  *"git add"*|*"git commit"*|*"git push"*)
    secret='(sk-[A-Za-z0-9]{16,}|api[_-]?key|secret[_-]?key|-----BEGIN [A-Z ]*PRIVATE KEY|password\s*=|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9A-Za-z-]+)'
    if printf '%s' "$payload" | grep -Eiq "$secret"; then
      printf '[확인 필요] 커밋/푸시에 민감정보(키·비밀번호 등)로 보이는 패턴. 공개 시 유출 위험. 진짜 비밀이면 커밋에서 빼고 환경변수로, 오탐이면 확인 후 재실행.\n' >&2
      exit 2
    fi
    ;;
esac


exit 0
