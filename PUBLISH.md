# 공개 창고 만들기 (최초 1회)

> 이 템플릿을 "원본 창고"로 깃허브에 한 번 올린다. 이후엔 여기서 가져다 쓴다.
> 깃허브 아이디(only-victory)가 이미 반영되어 있다.

## 1. 깃허브에서 빈 Public 레포 생성
- 이름: `agent-project-template`
- **Public**
- README·.gitignore·license **추가 안 함** (이미 이 폴더에 있음)

## 2. install.sh의 REPO 교체
`install.sh` 안:
```
REPO="only-victory/agent-project-template"
```

## 3. 올리기
이 폴더에서:
```bash
git init
git add .
git commit -m "agent-project-template 공개 창고 초기화"
git branch -M main
git remote add origin https://github.com/only-victory/agent-project-template.git
git push -u origin main
```

## 4. 확인
- README가 첫 화면에 보이는지
- `.env`·`.clasp.json` 등 민감 파일이 안 올라갔는지(.gitignore가 막음)

---

# 이제부터 새 프로젝트 시작할 때

프로젝트 폴더를 열고 터미널에서 한 줄이면 끝:
```bash
npx degit only-victory/agent-project-template .
sh setup-check.sh      # 채울 빈칸 확인
claude                 # → /init-project 또는 /spec
```

창고를 고치면(템플릿 개선), 그 이후 새로 시작하는 프로젝트부터 자동으로 최신본을 가져온다.
(이미 만든 프로젝트엔 소급 안 됨: 그게 정상. 각 프로젝트는 가져온 시점으로 고정.)
