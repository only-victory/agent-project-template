# --- 3) 이 프로젝트 검사: Node/TypeScript 웹·API ---------------------------
# 교체 가이드: package.json의 실제 script 이름에 맞춰라. 없는 단계는 지운다.
# 의존 설치는 lockfile 기준으로(재현성). 아래는 npm 기준: pnpm/yarn이면 바꿔라.

npm ci                          # lockfile 그대로 설치 (npm install 아님)
npm run lint                    # 린트 (없으면 삭제)
npx tsc --noEmit                # 타입체크 (JS 프로젝트면 삭제)
npm test --if-present           # 테스트 (있을 때만)
npm run build                   # 빌드 (SSR/번들이면 필수, 없으면 삭제)
# --------------------------------------------------------------------------
