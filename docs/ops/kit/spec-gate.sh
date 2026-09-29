#!/usr/bin/env sh
# 명세 게이트: 상태가 "착수(In Progress)"인 docs/plans/*.md 검사.
#  (1) 필수 3칸(진짜 목표 / 범위 / 수용 기준)이 비었거나 플레이스홀더면 exit 1.
#  (2) 인터뷰 완료 리포트 섹션이 없으면 exit 1 (깊이 무관: 인터뷰를 거쳤다는 증거).
# Draft·Done·템플릿은 검사 안 함. 의존: python3.
#
# 스캔 범위(v2.37): PLAN-*.md 고정이 아니라 "상태 보유 문서" 전체.
#   제외: CHANGELOG.md·INDEX.md·MEASUREMENTS.md·BACKLOG-deferred.md·*.template.md
#   이유(실마찰): PLAN- 접두사에 고정하면 RELEASE-*.md 같은 이름의 실제 완료 경로를
#   게이트가 아예 못 본다. "게이트가 훑는 파일 ≠ 실제로 일하는 파일" 사고 재발 방지.
#
# 판정 어휘(v2.39): "In Progress" 영문 리터럴 고정이 아니라 확장 가능한 사전.
#   이유(실마찰): golden-gate에서 이미 겪은 것과 같은 병을 spec-gate가 그대로 갖고
#   있었다. 실사용 레포가 "착수"·"진행 중"·"작업 중"으로 쓰면 그대로 통과해버려서
#   필수칸이 비어도 안 걸린다. v2.51부터 어휘는 `status-vocab.conf`(정본) 한 곳에 있다.
#   이 레포 표기와 다르면 그 파일만 넓힌다.
exec python3 - "$@" << 'PY'
import io, re, subprocess, sys
# v2.51: 상태 판정은 plan-status.sh(단일 판정기)가 한다. 어휘는 status-vocab.conf 정본.
#        이 파일엔 어휘도 제외 목록도 없다. 여기서 다시 적으면 형제 누락이 재발한다.
r = subprocess.run(["sh", "docs/ops/kit/plan-status.sh"], capture_output=True, text=True)
if r.returncode != 0:
    sys.stderr.write("spec-gate 실패: 상태 판정기(plan-status.sh) 오류\n  " + r.stderr)
    sys.exit(1)

req = ["진짜 목표", "범위", "수용 기준"]
bad = []
for line in r.stdout.splitlines():
    col = line.split("\t")
    f = col[0]
    if col[1] == "nostatus":
        bad.append(f"{f}: 상태 필드 없음. 머리말에 '상태: Draft/착수/완료' 한 줄을 추가하라 (게이트가 추측하지 않는다)")
        continue
    if col[1] != "1":   # open(착수·진행 중)이 아니면 명세 검사 대상 아님
        continue
    s = io.open(f, encoding="utf-8").read()
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
