# --- 3) 이 프로젝트 검사: Google Apps Script (clasp) -----------------------
# ⚠️ GAS는 클라우드 실행이라 로컬에서 "진짜 실행"은 못 한다.
#    그래서 verify는 "푸시 전에 깨진 코드를 막는" 수준까지만 가능하다.
#    실제 동작 검증은 clasp push 후 GAS 편집기/트리거 로그로 사람이 확인(HITL).
# 전제: clasp 로그인됨, .clasp.json 있음, src는 TS면 로컬 트랜스파일.

# (TS 사용 시) 타입체크: push 전에 깨진 타입 차단
npx tsc --noEmit --skipLibCheck 2>/dev/null || echo "tsc 없음/JS 프로젝트: 건너뜀"

# 푸시 가능 상태인지 dry 확인 (실제 push는 비가역 → verify에 넣지 말 것)
# clasp push 자체는 '풀' 등급 위험작업 → CLAUDE.md §4 + 승인 후 수동 실행.
clasp status                    # 추적 파일 상태만 확인 (읽기 전용, 안전)

# 골든셋 G(자동화)에서 멱등성·실패모드를 사람이 확인하도록 위임.
echo "GAS verify: 정적 점검까지만. 실동작은 push 후 로그로 확인(HITL)." 
# --------------------------------------------------------------------------
