#!/usr/bin/env sh
# 골든셋 게이트: 상태가 "닫힘/내보냄"으로 바뀐 docs/plans/*.md에
# 골든셋 검증 결과 표(## 골든셋 검증 결과 + 해당 G 항목 판정, 현행 G1~G19)가 없으면 exit 1.
#
# 의도: verify.sh(기술 통과)만으로는 "돌아가지만 목표와 다른" 결과를 못 막는다.
#       PLAN을 닫거나 RELEASE를 내보내기 전, 의미 검증(/validate)을 실제로
#       거쳤다는 증거를 강제한다.
#
# 검사 대상: 상태가 "닫힘/내보냄"인 문서만. In Progress·Draft·Blocked·템플릿은 건너뜀.
# (작업 중엔 골든셋이 없어도 정상: 닫을 때만 요구)
#
# 스캔 범위(v2.37): PLAN-*.md 고정이 아니라 "상태 보유 문서" 전체.
#   제외: CHANGELOG.md·INDEX.md·MEASUREMENTS.md·BACKLOG-deferred.md·*.template.md
#   이유(실마찰): 출시가 RELEASE-*.md 같은 다른 이름으로 나가면, PLAN- 접두사 고정
#   게이트는 그 파일을 아예 스캔하지 않아 골든셋 검증 없이 조용히 출시된다.
#
# 판정 어휘(v2.38): "Done" 영문 리터럴 고정이 아니라 문서 종류별 사전으로 확장.
#   이유(실마찰): 실사용 레포가 "완료"·"제출"·"배포"·"출시"로 쓰는데 영문 done만
#   찾아서 스캔 범위를 넓힌 뒤에도 계속 못 물었다. v2.51부터 닫힘 어휘는
#   `status-vocab.conf`(정본)의 PLAN_CLOSED·RELEASE_CLOSED에 있다. 이 레포 표기와
#   다르면 그 파일만 넓힌다(여기가 커스터마이즈 지점).
#
# 앵커 주의(v2.38): 상태 줄에 `^` 앵커를 걸지 않는다. 실사용 머리말은
#   `> 생성: ... · 최종 수정: ... · 상태: **배포 완료**`처럼 상태가 줄 가운데
#   오는 경우가 흔하다. 줄 머리 앵커는 이런 문서에서 조용히 아무것도 못 잡는다.
# 의존: python3.
exec python3 - "$@" << 'PY'
import io, re, subprocess, sys
# v2.51: 상태 판정은 plan-status.sh(단일 판정기)가 한다. 닫힘 어휘(PLAN_CLOSED·RELEASE_CLOSED)는
#        status-vocab.conf 정본. 이 파일에 어휘를 다시 적지 않는다.
r = subprocess.run(["sh", "docs/ops/kit/plan-status.sh"], capture_output=True, text=True)
if r.returncode != 0:
    sys.stderr.write("golden-gate 실패: 상태 판정기(plan-status.sh) 오류\n  " + r.stderr)
    sys.exit(1)

bad = []
rows = [l.split("\t") for l in r.stdout.splitlines()]
for col in rows:
    f = col[0]
    if col[1] == "nostatus" or col[2] != "1":   # 닫힘/내보냄이 아니면 건너뜀
        continue
    s = io.open(f, encoding="utf-8").read()
    # 골든셋 결과 섹션이 있는가
    if "골든셋 검증 결과" not in s and "Golden" not in s:
        bad.append(f"{f}: 골든셋 검증 결과 섹션 없음 (/validate 미실행 의심)")
        continue
    # G1~G3 판정이 채워졌는가 (같은 줄에 판정어가 있어야 함)
    missing = [g for g in ("G1", "G2", "G3")
               if not re.search(rf'{g}\b.*(Pass|Hold|Retry|통과|보류|재시도|✅|⚠|❌)', s)]
    if missing:
        bad.append(f"{f}: 골든셋 {', '.join(missing)} 판정 누락")

if bad:
    sys.stderr.write(
        "골든셋 게이트 실패: 닫기·내보내기 전 의미 검증(/validate)이 필요합니다:\n  "
        + "\n  ".join(bad) + "\n"
    )
    sys.exit(1)
print(f"golden-gate OK ({len(rows)}개 문서 훑음)")
PY
