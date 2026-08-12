# 사전 준비물 (PREREQUISITES)

> 이 템플릿을 새 PC에서 쓰기 전에 준비해야 할 것. 단계별로 필요한 것만 정리.

## 환경(OS) 먼저 확인 ─ 특히 Windows

**이 템플릿은 macOS / Linux 기준이다.** 검증·보호 스크립트(`verify.sh`·`guard.sh`·`*gate.sh`)가 셸 스크립트(`sh`)로 되어 있다.

| 환경 | 준비 | 작동 |
|------|------|------|
| **macOS / Linux** | 추가 준비 없음 | `sh`·`git` 기본 내장. 그대로 사용 |
| **Windows** | **WSL 또는 Git Bash 필수** | 아래 준비 후 그 셸에서 실행 |

**Windows 필수 준비** (둘 중 하나):
1. **WSL (권장)**: PowerShell 관리자 권한에서 `wsl --install` → 재부팅 → WSL(Ubuntu 등) 터미널에서 Claude Code 실행. macOS와 동일하게 100% 작동.
2. **Git Bash**: [git-scm.com](https://git-scm.com) 설치 → Git Bash 터미널에서 실행. `sh` 스크립트가 작동.

- IDE(Antigravity·VS Code 등)를 쓰면 **내장 터미널이 WSL/Git Bash를 가리키게** 설정 후 Claude Code 실행.
- **PowerShell·CMD 단독은 권장하지 않는다**: 방법론·슬래시 명령·권한 설정은 되지만, 검증 게이트와 위험 명령 차단 훅(`guard.sh`, 2차 안전망)이 동작하지 않아 안전망이 빠진다.

---

## 가져오기(다운로드)만 할 때: Node.js 하나면 끝

이 템플릿을 내 폴더로 받아오는 데 필요한 건 Node.js뿐이다.
(`npx degit`이 Node에 포함된 `npx`를 쓴다.)

```bash
node -v          # 버전 숫자가 나오면 준비 완료
```

없으면 설치:
- [nodejs.org](https://nodejs.org) 에서 다운로드
- 맥: `brew install node`

> install.sh(curl) 방식도 curl은 맥·리눅스 기본 내장이라 사실상 Node.js만 있으면 된다.

## 개발·검증까지 할 때 (가져온 뒤, 필요해지면)

가져오는 단계엔 필요 없고, 실제 작업할 때 쓰는 것들:

| 도구 | 용도 | 확인 |
|------|------|------|
| **Claude Code** | 슬래시 명령(`/spec` 등) 실행 | `claude --version` |
| **Python 3** | 게이트 스크립트(spec-gate·golden-gate) 실행 | `python3 --version` |
| **Git** | 버전 관리·푸시 | `git --version` |
| **스택별 도구** | 프로젝트 종류에 따라 그때 설치 | (예: GAS=clasp, Python=pytest) |

## 한 번에 점검

```bash
node -v && claude --version && python3 --version && git --version
```

전부 버전 숫자가 나오면 개발까지 준비 완료.
가져오기만 할 거면 맨 앞 `node -v` 하나만 통과하면 된다.
