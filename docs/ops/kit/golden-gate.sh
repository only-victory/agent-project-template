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
#   찾아서 스캔 범위를 넓힌 뒤에도 계속 못 물었다. **아래 CLOSED 사전이 이 레포의
#   실제 어휘와 다르면 프로젝트에서 직접 넓힌다** (스택 무관 원칙과 같은 이유로,
#   템플릿이 모든 언어·서식을 강제할 수 없다. 여기가 그 커스터마이즈 지점이다).
#
# 앵커 주의(v2.38): 상태 줄에 `^` 앵커를 걸지 않는다. 실사용 머리말은
#   `> 생성: ... · 최종 수정: ... · 상태: **배포 완료**`처럼 상태가 줄 가운데
#   오는 경우가 흔하다. 줄 머리 앵커는 이런 문서에서 조용히 아무것도 못 잡는다.
# 의존: python3.
exec python3 - "$@" << 'PY'
import glob, io, re, sys
EXCLUDE = {"CHANGELOG.md", "INDEX.md", "MEASUREMENTS.md", "BACKLOG-deferred.md"}

# 문서 종류별 "닫힘/내보냄" 어휘. 프로젝트 실제 표기에 맞게 이 사전만 넓히면 된다.
CLOSED = {
    "PLAN": r'done|완료',
    "RELEASE": r'done|완료|제출|배포|출시',
}
def kind_of(path):
    name = path.split("/")[-1]
    return "RELEASE" if name.startswith("RELEASE-") else "PLAN"

def status_value(s):
    """`상태:`/`status:` 뒤의 값(첫 등장). 줄 머리로 앵커하지 않는다:
    실사용 머리말은 상태가 줄 가운데(`... · 상태: ...`)에 오는 경우가 흔하다."""
    m = re.search(r'(?i)(?:상태|status)\s*[:|]\s*([^\n]*)', s)
    return m.group(1) if m else None

bad = []
files = [f for f in glob.glob("docs/plans/*.md")
         if f.split("/")[-1] not in EXCLUDE and not f.endswith(".template.md")]
for f in files:
    s = io.open(f, encoding="utf-8").read()
    value = status_value(s)
    kind = kind_of(f)
    if value is None or not re.search(CLOSED[kind], value, re.I):
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
        "골든셋 게이트 실패: 닫기·내보내기 전 의미 검증(/validate)이 필요합니다:\n  "
        + "\n  ".join(bad) + "\n"
    )
    sys.exit(1)
print(f"golden-gate OK ({len(files)}개 문서 훑음)")
PY
