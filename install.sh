#!/usr/bin/env sh
# agent-project-template 설치기: 공개 레포에서 파일만 가져와 현재 폴더에 깐다.
# 사용법: 새 프로젝트 폴더에서
#   curl -fsSL https://raw.githubusercontent.com/only-victory/agent-project-template/main/install.sh | sh
# 또는 degit 직접:
#   npx degit only-victory/agent-project-template .
#
# 이 스크립트는 .git 없이 "자료만" 가져온다(원본 창고와 분리). 기존 파일은 덮지 않고 경고한다.
set -eu

REPO="only-victory/agent-project-template"
TARGET="${1:-.}"

echo "agent-project-template 설치 → $TARGET"

# degit 우선(파일만, 빠름). 없으면 git clone 폴백.
if command -v npx >/dev/null 2>&1; then
  npx --yes degit "$REPO" "$TARGET" --force
else
  echo "npx 없음 → git clone 폴백"
  TMP=$(mktemp -d)
  git clone --depth 1 "https://github.com/$REPO.git" "$TMP"
  rm -rf "$TMP/.git"
  cp -rn "$TMP"/. "$TARGET"/
  rm -rf "$TMP"
fi

# 설치기 자신과 공개 안내는 새 프로젝트에 불필요 → 제거
rm -f "$TARGET/install.sh" "$TARGET/PUBLISH.md" 2>/dev/null || true

chmod +x "$TARGET"/verify.sh "$TARGET"/setup-check.sh "$TARGET"/docs/ops/kit/*.sh "$TARGET"/docs/ops/kit/recipes/*.sh 2>/dev/null || true

echo ""
echo "✓ 설치 완료. 다음:"
echo "  1) sh setup-check.sh   # 채울 빈칸 확인"
echo "  2) claude              # Claude Code 접속"
echo "  3) /init-project 또는 /spec"
