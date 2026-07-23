# verify.sh 레시피: 스택별 시작점

> 빈 verify.sh를 채울 때 복붙 시작점. **이건 "예시 패턴"이지 "정답"이 아니다.**
> 최종 검증일: 2026-06-21.

## ⚠️ 쓰기 전에 반드시
- 아래 명령들은 **패턴**이다. 당신 프로젝트의 실제 명령으로 **교체**하라.
- 도구 버전·플래그는 시간이 지나면 바뀐다. 박제하지 말고 프로젝트 기준으로 맞춰라.
- 안 쓰는 단계는 지워라. 있는 척하는 빈 검사는 가짜 안전감이다(harness-design 참조).
- 교체 후 반드시 한 번 로컬에서 돌려 `exit 0`이 나오는지 확인하라.

## 고르기
| 프로젝트 | 레시피 |
|----------|--------|
| Node/TypeScript 웹·API | `web-node.sh` |
| Python 자동화·스크립트 | `python.sh` |
| Google Apps Script | `gas-clasp.sh` |
| 정적 웹·슬라이드(Vercel 등) | `static-web.sh` |

## 설치
1. 맞는 레시피 내용을 루트 `verify.sh`의 "3) 이 프로젝트 검사" 자리에 붙인다.
2. 명령을 실제 프로젝트 명령으로 교체한다.
3. `chmod +x verify.sh` 후 `./verify.sh`로 확인.
> spec-gate·golden-gate(앞 1·2단계)는 그대로 둔다: 스택 무관 공통 게이트.

## 여러 스택을 함께 쓸 때 (혼용)
한 레포에 여러 스택이 섞이는 건 흔하다 (예: Node 백엔드 + GAS 연동, Python 처리 + 정적 대시보드).
이럴 땐 레시피를 **이어 붙인다**. verify.sh는 위에서 아래로 실행되고, 어느 한 줄이 실패하면 거기서 멈춘다(set -eu).

```sh
# 예) Node 앱 + GAS 연동 레포
npm ci && npm run lint && npx tsc --noEmit && npm test --if-present && npm run build   # web-node
npx tsc --noEmit --skipLibCheck 2>/dev/null || true                                    # gas 정적 점검
clasp status                                                                            # gas 추적 상태
```

원칙:
- **빠른 검사를 앞에** 둔다(린트·타입 먼저, 빌드·무거운 건 뒤). 빨리 실패할수록 좋다.
- 디렉터리별로 나뉘면 `cd`로 옮겨가며 각 스택 검사를 돌린다.
- 어느 스택도 "대표"가 아니다: 이 레포가 실제로 쓰는 것만 넣고 나머지는 지운다.
