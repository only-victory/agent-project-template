#!/usr/bin/env sh
# 골든셋 게이트: 상태가 "Done"으로 바뀐 docs/plans/PLAN-*.md에
# 골든셋 검증 결과 표(## 골든셋 검증 결과 + G1~G3 판정)가 없으면 exit 1.
#
# 의도: verify.sh(기술 통과)만으로는 "돌아가지만 목표와 다른" 결과를 못 막는다.
#       PLAN을 Done으로 닫기 전, 의미 검증(/validate)을 실제로 거쳤다는 증거를 강제한다.
#
# 검사 대상: 상태가 "Done"인 PLAN만. In Progress·Draft·Blocked·템플릿은 건너뜀.
# (작업 중엔 골든셋이 없어도 정상: 닫을 때만 요구)
# 의존: python3.
exec python3 - "$@" << 'PY'
import glob, io, re, sys
bad = []
for f in glob.glob("docs/plans/PLAN-*.md"):
    s = io.open(f, encoding="utf-8").read()
    # "Done" 상태인 PLAN만 검사 (상태 표기는 '상태: Done' 또는 'Status: Done' 등 허용)
    if not re.search(r'(?i)(상태|status)\s*[:|]\s*done', s) and "Done" not in s:
        continue
    # 골든셋 결과 섹션이 있는가
    if "골든셋 검증 결과" not in s and "Golden" not in s:
        bad.append(f"{f}: 골든셋 검증 결과 섹션 없음 (/validate 미실행 의심)")
        continue
    # G1~G3 판정이 채워졌는가 (Pass/Hold/Retry 또는 통과/보류/재시도 표기)
    missing = []
    for g in ["G1", "G2", "G3"]:
        # 같은 줄에 판정어가 있어야 함
        pat = re.compile(rf'{g}\b.*(Pass|Hold|Retry|통과|보류|재시도|✅|⚠|❌)')
        if not pat.search(s):
            missing.append(g)
    if missing:
        bad.append(f"{f}: 골든셋 {', '.join(missing)} 판정 누락")

if bad:
    sys.stderr.write(
        "골든셋 게이트 실패: Done 처리 전 의미 검증(/validate)이 필요합니다:\n  "
        + "\n  ".join(bad) + "\n"
    )
    sys.exit(1)
print("golden-gate OK")
PY
