#!/bin/sh
# session-metrics (SessionEnd 훅, 기본 꺼짐): 트랜스크립트에서 토큰 사용량을 파싱해
# docs/plans/MEASUREMENTS.md 에 한 줄 자동 기록. 사람이 /cost 안 쳐도 측정이 쌓임.
# 주의: 트랜스크립트는 내부 포맷이라 버전에 따라 깨질 수 있음 → 어떤 오류든 조용히 통과(exit 0).
payload=$(cat)
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
printf '%s' "$payload" | python3 -c "
import sys, json, datetime, os
try:
    d = json.load(sys.stdin)
    tp = d.get('transcript_path','')
    tin = tout = 0
    with open(os.path.expanduser(tp), encoding='utf-8') as f:
        for line in f:
            try:
                u = json.loads(line).get('message',{}).get('usage',{})
                tin += u.get('input_tokens',0) + u.get('cache_read_input_tokens',0)
                tout += u.get('output_tokens',0)
            except Exception: pass
    if tin+tout == 0: sys.exit(0)
    p = 'docs/plans/MEASUREMENTS.md'
    row = f\"| {datetime.date.today()} | (자동) | 입력 {tin:,} / 출력 {tout:,} | | | |\n\"
    open(p,'a',encoding='utf-8').write(row)
except Exception: pass
" 2>/dev/null
exit 0
