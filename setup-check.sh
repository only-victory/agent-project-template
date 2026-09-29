#!/usr/bin/env sh
# 셋업 완료 체크: 템플릿을 깐 뒤 한 번 실행해서 채워야 할 빈칸을 모아 본다.
# 이건 게이트가 아니라 "셋업 가이드". 실패해도 작업은 가능하나, 채울수록 완성형에 가까워진다.
echo "=== agent-project-template 셋업 체크 ==="
WARN=0

check() {
  if grep -q "$2" "$1" 2>/dev/null; then
    echo "  [ ] $3"
    echo "       → $1"
    WARN=$((WARN+1))
  else
    echo "  [x] $3"
  fi
}

echo ""
echo "필수 (안 채우면 verify/CI 막힘):"
check CLAUDE.md '<PROJECT_NAME>' "프로젝트명 (CLAUDE.md)"
check verify.sh 'verify.sh 미구현' "verify.sh 실제 검사 명령"

echo ""
echo "컨텍스트 무게 (실마찰: 상시 로드 문서가 자라도 측정이 없어 아무도 몰랐음):"
# v2.49: 단위를 바이트 → 글자로 교정. 한글은 UTF-8에서 글자당 3바이트라 바이트 기준이
#        토큰을 2~3배 부풀렸다(62KB로 보이던 것이 실제 31k 글자 ≈ 8k 토큰).
# 기준 40,000 글자의 근거: Claude Code /doctor 실측 33.2k 글자 = 약 8.3k 토큰(글자÷4),
#        v2.49 기본 상태 31k 글자 + 여유. /doctor의 파일당 경고선도 40k 글자다.
LIMIT_CHARS=40000
report=$(python3 - << 'PYC' 2>/dev/null
import io, os
fs = ['CLAUDE.md'] if os.path.exists('CLAUDE.md') else []
if fs:
    fs += [l[1:].strip() for l in io.open('CLAUDE.md', encoding='utf-8') if l.startswith('@') and os.path.exists(l[1:].strip())]
sizes = {f: len(io.open(f, encoding='utf-8').read()) for f in fs}
big = max(sizes, key=sizes.get) if sizes else '-'
print(sum(sizes.values()), big, sizes.get(big, 0))
PYC
)
total=$(echo "$report" | cut -d' ' -f1); biggest=$(echo "$report" | cut -d' ' -f2); bigsize=$(echo "$report" | cut -d' ' -f3)
if [ -z "$total" ]; then
  echo "  [ ] 측정 실패 (python3 필요). 측정 못 한 것을 통과로 치지 않는다"
  WARN=$((WARN+1))
elif [ "$total" -gt "$LIMIT_CHARS" ]; then
  echo "  [ ] 세션 자동 로드 ${total}자 (약 $((total/4)) 토큰, 기준 ${LIMIT_CHARS}자 초과). 가장 큰 파일: ${biggest} (${bigsize}자)"
  echo "       → 매 세션 필요 없는 내용이면 import에서 빼고 그 명령이 읽게 한다. Claude Code에서 /doctor로 교차 확인"
  WARN=$((WARN+1))
else
  echo "  [x] 세션 자동 로드 ${total}자 (약 $((total/4)) 토큰, 기준 ${LIMIT_CHARS}자 이내)"
fi

echo "CI 배선 (실마찰: 템플릿 자체 점검용 CI를 실제 프로젝트에 그대로 씀):"
if [ -f .github/workflows/verify.yml ] && ! grep -q './verify.sh' .github/workflows/verify.yml; then
  echo "  [ ] .github/workflows/verify.yml이 아직 '템플릿 자체 점검용'입니다"
  echo "       → 게이트 4종만 돌고 프로젝트 테스트(verify.sh)는 CI에서 한 번도 실행 안 됨"
  echo "       → docs/ops/kit/ci.example.yml 내용으로 .github/workflows/verify.yml을 교체하세요"
  WARN=$((WARN+1))
else
  echo "  [x] CI가 ./verify.sh를 실행함 (프로젝트 검사가 CI에 연결됨)"
fi

echo ""
echo "권장 (완성형 지표):"
check CLAUDE.md '<예: 핸들러' "코드 지형 §3"
check CLAUDE.md '<예: prod 배포' "위험 작업 목록 §4"
if grep -E '^담당:' docs/ops/multi-agent.md 2>/dev/null | grep -q '<이름 또는 팀>'; then
  if grep -E '^담당:' docs/ops/multi-agent.md | grep -q '\[SINGLE-AGENT\]'; then
    echo "  [x] 에스컬레이션 경로 (single-agent 면제)"
  else
    echo "  [ ] 에스컬레이션 경로 (multi-agent.md '담당:' 줄)"
    echo "       → 멀티에이전트면 채우고, 1인이면 [SINGLE-AGENT] 마커"
    WARN=$((WARN+1))
  fi
else
  echo "  [x] 에스컬레이션 경로"
fi

echo ""
if [ "$WARN" -eq 0 ]; then
  echo "✓ 셋업 완료: 빈칸 없음."
else
  echo "△ 채울 항목 $WARN개. 위 [ ] 항목을 채우면 완성형에 가까워집니다."
fi
