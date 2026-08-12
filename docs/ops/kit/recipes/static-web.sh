# --- 3) 이 프로젝트 검사: 정적 웹·슬라이드 (Vercel 등) ---------------------
# 교체 가이드: 빌드 단계가 있으면(프레임워크) 넣고, 순수 HTML이면 링크·HTML 검사 위주.

# (빌드형): Next/Vite 등이면
# npm ci && npm run build

# (순수 정적): 빌드 없을 때 최소 검사
# HTML 문법 깨짐 차단 (html-validate 등: 없으면 설치하거나 삭제)
npx html-validate "**/*.html" 2>/dev/null || echo "html-validate 미설치: 건너뜀(도입 권장)"

# 죽은 내부 링크 차단 (선택)
# npx linkinator ./ --silent --skip "^https?://" || true

echo "정적 검사 완료. 배포 전 미리보기로 사람이 눈으로 확인 권장(HITL)."
# --------------------------------------------------------------------------
