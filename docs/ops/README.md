# docs/ops: 하네스(강제) 설계 + 운영 루프 정본

- `agent-loop.md`: 행동 루프 정본 (루트 AGENTS.md가 @import)
- `spec-interview.md`: 착수 전 명세 인터뷰 절차(막연한 목표 방지, AGENTS.md가 @import)
- `harness-design.md`: 게이트 강도·설계 (셋업 때만 참조)
- `CLAUDE.template.md`: Claude Code 전용 대안(AGENTS.md와 내용 동일)
- `apply-loop.prompt.md`: 이 체제를 *기존* 다른 레포에 이식하는 부트스트랩 프롬프트
- `kit/`: verify.sh 원본 · hooks/guard.sh · ci.example.yml · settings.json · **spec-gate.sh**

설치형 게이트(실제 차단)는 루트 `.github/`·`.claude/`에 배치됨.
