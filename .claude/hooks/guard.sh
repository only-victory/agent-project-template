#!/usr/bin/env sh
# PreToolUse(Bash) 가드: 위험·비가역 명령을 모델 판단과 무관하게 차단.
# 차단은 exit 2 만 유효(exit 1은 경고일 뿐 통과됨). 빠르게(<500ms). 외부 의존 없음(POSIX sh + awk).
# 등록: .claude/settings.json (동봉). 정본은 이 파일 하나다(v2.50: kit 사본 폐기).
#
# v2.50 판정 방식: 문자열 일치 → 명령 토큰 판정.
#   이전 정규식은 22종 중 15종을 통과시켰다(rm -fr /, rm -r -f /, 인용된 "$HOME",
#   find -exec /bin/rm, git push +refspec, chmod -R /, curl|sh 등). 동시에 `-f` 부분 일치로
#   `git push origin fix/login-flow` 같은 정상 push를 막았다. 이제 명령을 구간(; && || | 등)으로
#   나누고, 구간마다 명령 이름과 옵션 토큰을 따로 본다.
# 입력: stdin JSON에서 "command" 값만 꺼낸다(설명 문구 오탐 방지).
#   꺼내기에 실패하면 원문 전체를 검사한다: 파괴적 패턴엔 오탐보다 과차단이 안전하다.
payload=$(cat)
[ -z "$payload" ] && exit 0

# --- 1) command 필드 추출 (JSON 문자열 이스케이프 해제) ---
cmd=$(printf '%s' "$payload" | awk '
  { s = s $0 "\n" }
  END {
    i = index(s, "\"command\""); if (i == 0) exit 1
    s = substr(s, i + 9); j = index(s, "\""); if (j == 0) exit 1
    s = substr(s, j + 1); n = length(s); out = ""; k = 1
    while (k <= n) {
      c = substr(s, k, 1)
      if (c == "\\") { d = substr(s, k + 1, 1); out = out ((d == "n" || d == "t") ? " " : d); k += 2; continue }
      if (c == "\"") { print out; exit 0 }
      out = out c; k++
    }
    exit 1
  }') || cmd=$payload

block() {
  printf '차단: %s. agent-loop 비협상: 계획→사용자 승인 후 진행하세요.\n' "$1" >&2
  exit 2
}

# --- 2) 정규화: 인용부호 제거, 공백 통일 ---
norm=$(printf '%s' "$cmd" | tr '\n\t' '  ' | sed "s/[\"']//g")

# --- 3) 구간 분리 전에 봐야 하는 패턴 (파이프·SQL·포크 폭탄) ---
if printf '%s' "$norm" | grep -Eiq '(curl|wget)[^|]*\| *(sudo +)?(ba|z|da|k)?sh( |$)'; then
  block "원격 스크립트를 셸로 바로 실행(curl|sh)"
fi
if printf '%s' "$norm" | grep -Eiq 'drop +(table|database|schema)|truncate +table'; then
  block "데이터 삭제 SQL(DROP·TRUNCATE)"
fi
if printf '%s' "$norm" | tr -d ' ' | grep -qF ':(){'; then
  block "포크 폭탄"
fi

# --- 4) 구간별 토큰 판정 ---
reason=$(printf '%s' "$norm" | tr ';|&(){}`' '\n\n\n\n\n\n\n\n' | awk '
  function base(t) { sub(/.*\//, "", t); return t }
  function danger(t) {   # 루트·홈·상위·현재 디렉터리 전체
    if (t ~ /^(\/|\/\*|~|~\/|~\/\*|\.\.|\.\.\/|\.\.\/\*|\*|\.|\.\/|\.\/\*)$/) return 1
    if (t ~ /^\$([{]HOME[}]|HOME)\/?\*?$/) return 1
    return sysdir(t)
  }
  function sysdir(t) {   # 시스템 최상위 디렉터리
    if (t == "/" || t == "/*") return 1
    if (t ~ /^~\/?\*?$/ || t ~ /^\$([{]HOME[}]|HOME)\/?\*?$/) return 1
    return (t ~ /^\/(bin|boot|dev|etc|home|lib|lib64|opt|root|sbin|srv|sys|usr|var|System|Users|Library|Applications|Volumes)\/?\*?$/)
  }
  {
    n = split($0, a, " "); s = 1
    # 앞에 붙는 실행 래퍼는 건너뛴다
    while (s <= n && (a[s] ~ /^(sudo|env|command|exec|nohup|time|nice|xargs)$/ || a[s] ~ /^[A-Za-z_][A-Za-z0-9_]*=/ || (s > 1 && a[s] ~ /^-/ && a[s-1] ~ /^(sudo|xargs|env|nice)$/))) s++
    if (s > n) next
    c = base(a[s])

    if (c == "rm") {
      r = 0; tgt = 0; eo = 0
      for (k = s + 1; k <= n; k++) { t = a[k]
        if (!eo && t == "--") { eo = 1; continue }
        if (!eo && t == "--recursive") { r = 1; continue }
        if (!eo && t ~ /^--/) continue
        if (!eo && t ~ /^-[A-Za-z]+$/) { if (t ~ /[rR]/) r = 1; continue }
        if (danger(t)) tgt = 1 }
      if (r && tgt) { print "재귀 삭제 대상이 루트·홈·상위·현재 디렉터리 전체"; exit }
    }
    if (c == "find") {
      p = 0; del = 0
      for (k = s + 1; k <= n; k++) { t = a[k]
        if (t ~ /^[-!]/) break
        if (danger(t)) p = 1 }
      for (k = s + 1; k <= n; k++) {
        if (a[k] == "-delete") del = 1
        if (a[k] ~ /^-(exec|execdir|ok|okdir)$/ && k < n && base(a[k+1]) == "rm") del = 1 }
      if (p && del) { print "find 삭제형(-delete·-exec rm)이 루트·홈·상위 경로 대상"; exit }
    }
    if (c == "git") {
      k = s + 1
      while (k <= n && a[k] ~ /^-/) { if (a[k] == "-C" || a[k] == "-c") k++; k++ }
      sub_ = a[k]
      for (m = k + 1; m <= n; m++) { t = a[m]
        if (sub_ == "push" && (t ~ /^--force/ || t ~ /^-[A-Za-z]*f[A-Za-z]*$/ || t ~ /^\+/)) { print "강제 push(--force·-f·+refspec)"; exit }
        if (sub_ == "reset" && t == "--hard") { print "git reset --hard(작업 내용 소실)"; exit }
        if (sub_ == "clean" && (t == "--force" || t ~ /^-[A-Za-z]*f[A-Za-z]*$/)) { print "git clean -f(추적 안 된 파일 삭제)"; exit }
      }
    }
    if (c == "chmod" || c == "chown" || c == "chgrp") {
      r = 0; tgt = 0
      for (k = s + 1; k <= n; k++) { t = a[k]
        if (t == "--recursive" || t ~ /^-[A-Za-z]*R[A-Za-z]*$/) r = 1
        else if (sysdir(t)) tgt = 1 }
      if (r && tgt) { print "재귀 권한 변경이 시스템·홈 디렉터리 대상"; exit }
    }
    if (c ~ /^mkfs/) { print "파일시스템 포맷(mkfs)"; exit }
    if (c == "dd") { for (k = s + 1; k <= n; k++) if (a[k] ~ /^(if|of)=/) { print "dd 원시 쓰기"; exit } }
  }')
[ -n "$reason" ] && block "$reason"

# --- 5) 공개 유출 방지: git add/commit/push에 민감정보가 섞였는지 확인 ---
case "$cmd" in
  *"git add"*|*"git commit"*|*"git push"*)
    secret='(sk-[A-Za-z0-9]{16,}|api[_-]?key|secret[_-]?key|-----BEGIN [A-Z ]*PRIVATE KEY|password\s*=|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9A-Za-z-]+)'
    if printf '%s' "$cmd" | grep -Eiq "$secret"; then
      printf '[확인 필요] 커밋/푸시에 민감정보(키·비밀번호 등)로 보이는 패턴. 공개 시 유출 위험. 진짜 비밀이면 커밋에서 빼고 환경변수로, 오탐이면 확인 후 재실행.\n' >&2
      exit 2
    fi
    # v2.47: 명령 문자열만이 아니라 스테이징된 파일명도 본다. (.env·키 파일이 add된 채 commit되는 구멍 차단)
    case "$cmd" in *"git commit"*|*"git push"*)
      staged=$(git diff --cached --name-only 2>/dev/null)
      if printf '%s\n' "$staged" | grep -Eq '(^|/)\.env($|\.)|\.(pem|key|p12|pfx)$|credentials|secrets?\.(json|ya?ml)$'; then
        printf '[차단] 스테이징에 비밀 파일이 있다: %s\n.gitignore에 넣고 git rm --cached 로 뺀 뒤 다시 커밋.\n' "$(printf '%s\n' "$staged" | grep -Eo '(^|/)\.env[^ ]*|[^ ]*\.(pem|key|p12|pfx)|[^ ]*credentials[^ ]*|[^ ]*secrets?\.(json|ya?ml)' | tr '\n' ' ')" >&2
        exit 2
      fi
      ;;
    esac
    ;;
esac

exit 0
