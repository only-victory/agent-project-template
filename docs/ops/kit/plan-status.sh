#!/usr/bin/env sh
# plan-status: docs/plans 상태 보유 문서의 상태를 판정해 출력하는 단일 판정기 (v2.51).
# 게이트(spec·golden)와 훅(stop-verify-gate·session-start)이 모두 이걸 부른다.
# 판정 로직이 한 곳에만 있어야 형제 누락이 안 생긴다(guardrails 게이트 설계 원칙).
#
# 출력: 한 줄에 한 문서, 탭 구분
#   <경로>  <open 0|1>  <closed 0|1>  <blocked 0|1>  <상태값 원문>
#   상태 필드가 없는 PLAN-·RELEASE- 문서는 "<경로>  nostatus" 로 출력(게이트가 실패 처리).
#   그 외 이름의 무상태 문서(메모 등)는 출력하지 않는다.
# 판정 규칙:
#   상태값 = 문서 안 첫 "상태:" 또는 "status:"(대소문자 무시, ':' 대신 '|'도 허용) 뒤의 그 줄 나머지.
#   줄 머리 앵커 없음: "> 생성: ... · 상태: ..." 처럼 줄 가운데 있어도 잡는다.
#   closed 어휘는 RELEASE- 문서면 RELEASE_CLOSED, 나머지는 PLAN_CLOSED.
# 실패: 어휘 정본(status-vocab.conf)이 없으면 exit 1. 못 읽은 것을 통과로 치지 않는다.
# 의존: POSIX sh + awk (python 불필요).
root=${1:-.}
conf="$root/docs/ops/kit/status-vocab.conf"
if [ ! -f "$conf" ]; then
  echo "plan-status: 상태 어휘 정본이 없다: $conf" >&2
  exit 1
fi
get() { sed -n "s/^$1=//p" "$conf" | head -1; }
ip=$(get IN_PROGRESS); bl=$(get BLOCKED); pc=$(get PLAN_CLOSED); rc=$(get RELEASE_CLOSED); ex=$(get EXCLUDE)
if [ -z "$ip" ] || [ -z "$pc" ] || [ -z "$rc" ]; then
  echo "plan-status: $conf 에 IN_PROGRESS·PLAN_CLOSED·RELEASE_CLOSED 중 빈 항목이 있다" >&2
  exit 1
fi

for f in "$root"/docs/plans/*.md; do
  [ -f "$f" ] || continue
  b=${f##*/}
  case "$b" in *.template.md) continue ;; esac
  case " $ex " in *" $b "*) continue ;; esac
  awk -v f="${f#./}" -v b="$b" -v ip="$ip" -v bl="$bl" -v pc="$pc" -v rc="$rc" '
    !found {
      l = tolower($0)
      if (match(l, /(상태|status)[ \t]*[:|][ \t]*/)) { v = substr($0, RSTART + RLENGTH); found = 1 }
    }
    END {
      if (!found) { if (b ~ /^(PLAN|RELEASE)-/) print f "\tnostatus"; exit }
      lv = tolower(v); cl = (b ~ /^RELEASE-/) ? rc : pc
      o = (lv ~ tolower(ip)) ? 1 : 0
      c = (lv ~ tolower(cl)) ? 1 : 0
      k = (bl != "" && lv ~ tolower(bl)) ? 1 : 0
      print f "\t" o "\t" c "\t" k "\t" v
    }' "$f"
done
exit 0
