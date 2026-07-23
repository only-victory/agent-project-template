#!/usr/bin/env sh
# 명세 게이트: 상태가 "In Progress"인 docs/plans/PLAN-*.md 검사.
#  (1) 필수 3칸(진짜 목표 / 범위 / 수용 기준)이 비었거나 플레이스홀더면 exit 1.
#  (2) 인터뷰 완료 리포트 섹션이 없으면 exit 1 (깊이 무관: 인터뷰를 거쳤다는 증거).
# Draft·Done·템플릿은 검사 안 함. 의존: python3.
exec python3 - "$@" << 'PY'
import glob, io, re, sys
req = ["진짜 목표", "범위", "수용 기준"]
bad = []
for f in glob.glob("docs/plans/PLAN-*.md"):
    s = io.open(f, encoding="utf-8").read()
    if "In Progress" not in s:
        continue
    # (1) 필수 3칸 본문 검사
    parts = re.split(r'(?m)^#{1,6}\s+', s)
    for need in req:
        body = ""
        for sec in parts:
            first = sec.splitlines()[0] if sec.strip() else ""
            if need in first:
                body = "\n".join(sec.splitlines()[1:])
                break
        clean = re.sub(r'<[^>]*>|<\.\.\.>|⛳|`|\s', '', body)
        if not clean:
            bad.append(f"{f}: '{need}' 비어 있음")
    # (2) 인터뷰 리포트 존재 검사 (깊이 무관: 인터뷰를 거쳤는가)
    if "인터뷰 완료 리포트" not in s and "인터뷰" not in s:
        bad.append(f"{f}: 인터뷰 완료 리포트 없음 (spec-interview 미실행 의심)")

if bad:
    sys.stderr.write("명세 게이트 실패: 필수칸/인터뷰 미작성:\n  " + "\n  ".join(bad) + "\n")
    sys.exit(1)
print("spec-gate OK")
PY
