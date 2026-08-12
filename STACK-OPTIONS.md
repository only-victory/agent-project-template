# STACK-OPTIONS.md: 스택 선택 참고 카탈로그

> **파일명 유래**: 프로젝트 스택을 고를 때 "어떤 선택지가 있나"를 보여주는 참고 목록(options catalog).
> **이건 정보 제공용이다. 강요·권장이 아니다.** 프로젝트·지역·취향에 맞게 고르거나, **여기 없는 걸 써도 된다.** 결정은 사람이 한다.
> 자동 로드되지 않는다(토큰 절약). 스택이 막막할 때 열어보는 참고 문서다.
>
> 최종 갱신: 2026-07-01 (전체 카테고리 인기 항목 보충)

---

## 이 문서의 수록 원칙 (아무거나 넣지 않는다)

이 목록의 가치는 "빠짐없음"이 아니라 **"검증된 것만 빠짐없음"**이다.

1. **잘 알려지고 널리 쓰이는 것 위주.** 채택도(많은 사람이 실제로 쓴다)가 곧 검증이다. 나온 지 얼마 안 된 "요즘 뜨는" 기술은 본 목록이 아니라 아래 "떠오르는" 섹션에 둔다.
2. **"누락없이"의 뜻**: *잘 알려진 후보를* 빠짐없이 담는다는 것이지, 무명·신생 기술까지 다 담는다는 게 아니다. 널리 쓰인다는 필터가 목록을 유용하게 유지한다.
3. **성숙도**: 최소 1~2년 이상 유지되고 관리가 활발한 것.
4. **지역 특화는 라벨을 붙인다** (예: 🇰🇷 한국). 다른 지역 사용자가 "이건 내 지역 걸 쓰면 되겠다"고 판단하게.

> 이 문서는 웹 서비스 스택 중심이다. 다른 도메인(모바일·데이터·게임 등)은 필요해지면 섹션을 추가한다.

---

## 1. 기반 및 프레임워크

| 항목 | 대표 | 대안 |
|------|------|------|
| 언어 | TypeScript | JavaScript, Python, Go, Rust |
| 런타임 | Node.js | Bun, Deno |
| 웹 프레임워크(React 계열) | Next.js | Remix, Astro |
| 웹 프레임워크(비React) | SvelteKit | Nuxt(Vue), Angular, SolidStart |
| 백엔드 프레임워크 | (Next.js 풀스택) | Express, NestJS, Fastify, Hono(엣지), FastAPI·Django(Python), Spring Boot(Java), Rails(Ruby), Laravel(PHP) |
| 패키지 매니저 | pnpm | npm, yarn, bun |

## 2. 도구 및 AI 에이전트

| 항목 | 대표 | 대안 |
|------|------|------|
| IDE | VS Code | Cursor, WebStorm, JetBrains 계열 |
| AI 코딩 에이전트 | Claude Code | Cursor Agent, GitHub Copilot, Codex |

## 3. 인프라 및 백엔드

| 항목 | 대표 | 대안 |
|------|------|------|
| 버전관리 호스팅 | GitHub | GitLab, Bitbucket |
| 배포(프론트/풀스택) | Vercel | Netlify, Cloudflare Pages, Railway, Render, Fly.io |
| 백엔드+DB(BaaS) | Supabase | Firebase, Convex, PlanetScale, Turso |
| 데이터베이스(직접) | PostgreSQL | MySQL, SQLite, MongoDB, Redis(캐시) |
| ORM·DB 접근(TS) | Prisma | Drizzle(엣지·경량), Kysely(쿼리빌더), TypeORM |
| 인증 | Supabase Auth | Clerk, Auth0, NextAuth, 🇰🇷 카카오/네이버 로그인 |

## 4. 화면 및 컴포넌트

| 항목 | 대표 | 대안 |
|------|------|------|
| CSS | Tailwind CSS | CSS Modules, styled-components, vanilla-extract |
| 컴포넌트 | shadcn/ui | MUI, Chakra UI, Radix UI, Mantine |
| 애니메이션(2D) | Motion(Framer Motion) | GSAP, Lenis(스크롤), Auto-Animate |
| 3D(코드) | React Three Fiber | Three.js(직접), Babylon.js |
| 3D(노코드) | Spline | Sketchfab |
| 클라이언트 상태관리 | Zustand | Redux Toolkit, Jotai(atomic), (작으면 React 내장) |
| 서버 상태·데이터 페칭 | TanStack Query | SWR, tRPC(타입안전 API) |
| 폼 | React Hook Form | Formik, (+ Zod 스키마 검증) |

## 5. 결제 및 알림 🇰🇷 (한국 특화 ─ 지역 다르면 해당 지역 서비스로)

| 항목 | 대표 | 대안 |
|------|------|------|
| 결제/본인인증 🇰🇷 | 포트원(PortOne) | 토스페이먼츠, KG이니시스, (해외: Stripe, Paddle) |
| 알림 발송 🇰🇷 | 카카오 알림톡 | NHN Cloud, 알리고, (해외: Twilio) |

## 6. 운영 및 데이터

| 항목 | 대표 | 대안 |
|------|------|------|
| 백그라운드 작업 | Inngest | Trigger.dev, QStash, BullMQ |
| 데이터 수집(크롤링) | Apify | Firecrawl, Bright Data |
| 제품 분석 | PostHog | Plausible, Mixpanel, Amplitude, GA4 |
| 에러 모니터링 | Sentry | Datadog, Rollbar |

## 7. 기타 확장 (선택)

| 항목 | 대표 | 대안 |
|------|------|------|
| 자동 테스트(E2E) | Playwright | Cypress |
| 자동 테스트(단위) | Vitest | Jest |
| 린터·포매터 | ESLint + Prettier | Biome(올인원·빠름) |
| CI/CD | GitHub Actions | GitLab CI, CircleCI |
| 이메일 발송 | Resend | Postmark, SendGrid, AWS SES |
| 검색 | Algolia | Meilisearch, Typesense |
| 헤드리스 CMS | Sanity | Strapi, Contentful, Payload |
| 파일/이미지 | Cloudinary | Uploadthing, AWS S3, imgix |
| 고객 채팅 | Intercom | Crisp, Plain, Channel Talk(🇰🇷) |
| 마케팅 사이트(노코드) | Framer | Webflow |
| 내부 협업 | Notion | Linear, Slack |

---

## 8. 에셋·리소스 (만든 것에 넣을 재료 ─ "기술"이 아니라 "재료")

> 스택(어떻게 만드나)과 구분되는, 프로젝트에 넣는 재료. 3D 프로젝트·게임·비주얼 작업에서 "모델·소리·이미지 어디서 구하지"의 답. **라이선스 필수 확인**: CC0=출처 표기 없이 상업적 사용 가능(가장 안전), CC-BY=출처 표기 필요. 쓰기 전 각 에셋의 라이선스를 반드시 본다.

| 항목 | 대표 | 대안 | 라이선스 |
|------|------|------|----------|
| 3D 모델(로우폴리·스타일) | Kenney, Quaternius | KayKit, Synty POLYGON(무료 팩) | CC0 (Synty 일부 유료) |
| 3D 모델(사실적·환경) | Poly Haven | Sketchfab(무료 필터), CraftPix | CC0 (Sketchfab은 항목별) |
| 텍스처·재질(PBR)·HDRI | Poly Haven, ambientCG | CGBookcase, Texture Ninja | CC0 |
| 캐릭터 애니메이션·리깅 | Mixamo(Adobe) | (KayKit 리깅 모델) | 무료(상업 가능) |
| 사운드·효과음 | Freesound(CC0 필터) | Kenney 오디오 팩 | 항목별(CC0 필터 권장) |
| 폰트(한글) 🇰🇷 | Pretendard | Noto Sans KR, 본고딕 | OFL(무료) |
| 아이콘 | Lucide | Heroicons, Tabler Icons, Phosphor | MIT/오픈 |
| 이미지·사진(무료) | Unsplash | Pexels, Pixabay | 각 사이트 라이선스 |
| 종합 검색(여러 CC0 한번에) | itch.io(CC0 태그) | OpenGameArt, awesome-cc0 목록 | 항목별 |

> **AI 생성 대안**: 원하는 에셋이 없으면 AI 3D 생성 도구(텍스트·이미지→3D)도 있다. 단 스타일 일관성·품질은 위 검증된 라이브러리가 대개 낫다.



> 요즘 언급이 늘지만 아직 "누구나 쓴다"고 하긴 이른 것들. 써보고 널리 검증되면 위 본 목록으로 승격, 아니면 삭제한다. **본 목록의 안정성을 흐리지 않도록 여기 격리한다.**

- (현재 비어 있음 ─ 관찰 대상이 생기면 날짜와 함께 추가)

---

## 이 문서를 최신으로 유지하는 법

"매번 업데이트"의 핵심: **자동으로 최신을 쫓지 않는다.** 트렌드 자동 반영은 검증을 건너뛰어 "예쁜 쓰레기"를 부른다. 대신 **손볼 때 검증 필터를 거쳐 의식적으로 갱신**한다.

1. **문서를 열 때 웹서치로 후보 확인**: 카테고리별로 "most popular \<카테고리\> 2026", "\<카테고리\> comparison" 등을 검색해 새로 널리 쓰이게 된 것을 찾는다. (AI에게 "이 카테고리에 요즘 널리 쓰이는 거 있어? 성숙도·채택도도 같이 봐줘"라고 요청하면 검증 필터까지 걸어준다.)
2. **채택 필터 적용**: 널리 쓰이고 성숙한 것만 본 목록에. 뜨지만 대세 전이면 "떠오르는" 섹션에.
3. **실사용 우선**: 직접 써보고 좋았던 건 가장 믿을 만한 추가 근거다.
4. **갱신 로그 + 최종 갱신일 기록**: 아래에 무엇을 추가/이동/삭제했는지 남긴다. 헤더의 "최종 갱신"도 그날로 갱신.
5. **주기적 재검토**: 오래된 항목이 여전히 유효한지(죽지 않았는지) 가끔 확인. 죽은 건 삭제.

---

## 갱신 로그

- 2026-06-30: 최초 작성. 웹 서비스 스택 7개 카테고리 + 한국 특화 라벨.
- 2026-07-01: §8 에셋·리소스 섹션 추가(3D 모델·텍스처·애니메이션·사운드·아이콘·이미지). 웹서치로 2026 기준 널리 쓰이는 CC0/무료 소스 검증. 폰트를 화면→에셋으로 이동.
- 2026-07-01: 전체 카테고리 인기 항목 보충(2026 채택도 검증). 추가: 백엔드 대안(Fastify·Hono·Spring·Rails·Laravel), ORM 행(Prisma·Drizzle·Kysely), 배포 대안(Render·Fly.io), 상태관리(Zustand), 서버상태(TanStack Query), 폼(React Hook Form), 린터(ESLint·Biome), Redis. 채택도 필터만 적용, 신생 트렌드는 제외.
