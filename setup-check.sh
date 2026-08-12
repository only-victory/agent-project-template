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
