## Research Output Structure

리서치 결과는 **리서치 주제별 폴더**로 관리한다. 하나의 리서치 세션은 하나의 폴더에 모든 산출물을 보관한다.

### 디렉토리 구조

```
docs/
├── research/
│   └── {date}-{topic}/           # 리서치별 폴더
│       ├── {관점1}.md
│       ├── {관점2}.md
│       └── ...
└── dev-journal/
    └── {date}-{project}.md       # 저널 (날짜별 플랫 구조 유지)
```

### 네이밍 컨벤션

- 리서치 폴더: `docs/research/{YYYY-MM-DD}-{topic-slug}/`
  - 예: `docs/research/2026-03-18-stock-ml-breakout/`
  - 예: `docs/research/2026-03-19-portfolio-optimization/`
- 폴더 내 파일: 관점/역할 기반 이름 (예: `ml-perspective-evaluation.md`, `market-perspective-evaluation.md`)
- 저널: `docs/dev-journal/{YYYY-MM-DD}-{project}.md` (기존 플랫 구조 유지)

### 서브 에이전트 산출물 규칙

- 서브 에이전트는 **반드시 지정된 리서치 폴더 안에** 결과를 저장한다.
- 메인 에이전트가 리서치 시작 시 폴더를 미리 생성하고, 서브 에이전트 프롬프트에 경로를 명시한다.
- loose 파일을 `docs/research/` 루트에 직접 놓지 않는다.

## Sub-Agent Permissions

서브 에이전트는 리서치 결과를 `docs/` 디렉토리 하위에 자유롭게 저장할 수 있어야 한다.

- `docs/dev-journal/` — 저널 파일 생성/수정 허용
- `docs/research/{date}-{topic}/` — 리서치 보고서 생성/수정 허용 (리서치별 폴더 안에서만)
- 서브 에이전트에게 `Write`, `Bash(mkdir)` 권한을 docs/ 하위에 대해 허용한다.
- 리서치 결과가 파일로 저장되지 못하면 딥리서치의 핵심 가치(축적·재활용)가 훼손된다.

### 검색 도구 접근 방식

- 검색은 MCP 서버가 아닌 **`./scripts/search.sh`** 스크립트를 통해 API를 직접 호출한다.
- 이 방식은 MCP 로드 실패, background 서브에이전트 MCP 접근 불가 등의 문제를 우회한다.
- 서브 에이전트는 `Bash` 도구로 `./scripts/search.sh`를 호출하면 된다.
- API 키는 프로젝트 루트 `.env`에서 자동 로드된다.

---

## Multi-Agent Research Policy

- 기본 원칙: 속도보다 품질을 우선한다.
- 메인 에이전트는 복잡한 리서치/분석/설계 작업을 직접 수행하지 않고, 서브 에이전트를 조직하고 통합하는 역할을 맡는다.
- 메인의 역할:
  - 사용자 요구 해석
  - 문제 정의 및 범위 조정
  - 서브 에이전트 구성 및 태스크 분배
  - 중간 결과 검토
  - 추가 조사 여부 판단
  - 상충 결과 조정
  - 최종 결과 통합

### 메인 에이전트 직접 처리 예외

아래 경우에는 메인이 직접 처리할 수 있다.

- 한 줄 수준의 확인
- 사소한 수정/표현 변경/포맷 수정
- 기존 정보 재구성만으로 가능한 작업
- 사용자가 직접 답변만 요구한 경우
- 멀티에이전트 분해 실익이 낮은 경우

단, 품질 저하 우려가 있으면 서브 에이전트를 우선한다.

---

## Required Sub-Agents

복잡한 리서치에서는 필요에 따라 아래 역할을 사용한다.

- Researcher: 자료 조사, 개념 정리, 초안 작성
- Critic: 논리적 허점, 반례, 과도한 일반화 탐지
- Verifier: 사실 검증, 근거 수준 구분, 불확실성 표시
- Synthesizer: 결과 통합, 중복 제거, 핵심 구조화
- Journal: 세션 기록, 의사결정 로그, TODO 관리

에이전트 수를 늘리는 것 자체가 목적이 아니다.\
분업은 관점 분리, 검증 강화, 통합 품질 향상에 기여할 때만 사용한다.

### Multi-Agent Shared Convention

복수의 서브 에이전트가 동일 도메인의 산출물을 각각 작성할 때,
에이전트 발사 전에 공유 컨벤션(네임스페이스, 용어, 포맷)을 정의하여
각 에이전트 프롬프트에 포함한다.

---

## Journal Policy

- 의미 있는 리서치 세션에서는 저널 전담 에이전트를 반드시 1개 spawn한다.
- 저널 경로:
  - `docs/dev-journal/{date}-{project}.md`

### 저널 최소 기록 항목

- 세션 메타
- 사용자 요청 요약
- 문제 정의
- 핵심 가정
- 의사결정 로그
- 이슈 / 해결
- TODO
- rejected alternatives

### 저널 생략 가능 예외

- 아주 짧은 확인
- 오타 수정
- 표현 다듬기
- 단순 재포맷팅

---

## Design-First Policy

- 새 기능, 리팩토링, 구조 변경, 방법론 변경은 즉시 구현하지 않는다.
- 먼저 설계 논의를 수행하고, 합의된 전략을 저널에 기록한 뒤 실행한다.
- 설계 논의에서는 최소한 아래를 점검한다:
  - 문제 정의가 맞는가
  - 더 나은 접근이 있는가
  - 대안과 트레이드오프는 무엇인가
  - 실패 가능성은 무엇인가
  - 검증 방법은 무엇인가

---

## Requirement Validation Policy

- 사용자의 초기 요청을 그대로 실행하지 말고, 그것이 최선의 문제 정의인지 먼저 검토한다.
- 아래 경우에는 반드시 재검토한다:
  - 요청이 모호한 경우
  - 더 적절한 접근이 보이는 경우
  - 비용이 큰 작업인 경우
  - 장기 구조에 영향을 주는 경우

질문이 꼭 필요하지 않다면, 가정을 명시하고 가장 타당한 방향으로 진행한다.

---

## Final Integration Policy

- 서브 에이전트 결과를 그대로 병합하지 않는다.
- 메인 에이전트는 반드시 다음을 수행한다:
  - 중복 제거
  - 상충점 정리
  - 근거 강도 평가
  - 결론 우선순위화
  - 불확실성 명시
  - 후속 액션 제안

최종 결과는 단순 요약이 아니라, 검토와 통합을 거친 판단이어야 한다.

---

## Failure Prevention

다음을 피한다.

- 실질 분업 없는 형식적 멀티에이전트
- 검증 없는 통합
- 중복 조사
- 근거 없는 강한 결론
- 기록만 많고 의사결정 이유가 없는 저널
- 설계만 길고 실행이 없는 상태

품질 우선은 느려도 된다는 뜻이지, 불필요하게 비효율적이어도 된다는 뜻은 아니다.

---

## Search Tool Usage Policy

검색은 `./scripts/search.sh`를 통해 수행한다. 조사는 아래 흐름을 따른다.

### 조사 흐름

조사는 얕은 곳에서 깊은 곳으로 진행한다. 각 단계에서 충분하면 멈춘다.

**1단계: 종합 파악** — 주제의 윤곽, 핵심 키워드, 주요 플레이어를 잡는다.

| 도구 | 호출 | 강점 |
| --- | --- | --- |
| Perplexity search | `./scripts/search.sh perplexity search "query"` | 합성 답변 + 인용. 개념 정리에 최적. ~$0.01 |
| Tavily search | `./scripts/search.sh tavily search "query" --depth advanced` | 구체적 URL 반환. 프로젝트/코드/제품 탐색에 최적. 2크레딧 |

Perplexity는 종합에 강하고 Tavily는 구체적 발견에 강하다. **한 도구에 편중하지 말고 섞어 쓴다.**

**2단계: 원문 검증** — 핵심 주장의 1차 출처를 확인한다.

| 도구 | 호출 | 용도 |
| --- | --- | --- |
| Tavily extract | `./scripts/search.sh tavily extract "url1,url2"` | 특정 URL의 전문 텍스트 확보. 1크레딧/URL |

아래 경우 반드시 extract로 원문을 확인한다:
- 보고서 핵심 결론을 뒷받침하는 **수치나 성능 데이터**
- 검색 결과 간 **상충하는 정보**
- 2차 출처(블로그, 뉴스)에서만 나오는 주장

**3단계: 심층 탐구** — 일반 검색으로 충분한 정보를 얻지 못할 때만 사용한다.

| 도구 | 호출 | 비용 |
| --- | --- | --- |
| Tavily research | `./scripts/search.sh tavily research "query"` | 5크레딧. 원문 포함 다면적 분석 |
| Perplexity research | `./scripts/search.sh perplexity research "query"` | 30초+. 심층 합성 |
| Perplexity reason | `./scripts/search.sh perplexity reason "query"` | 복잡한 비교/추론 |

트리거: 선행 연구가 적은 영역, 반례 탐색이 필요한 경우, 1-2단계 결과가 피상적일 때.

### 사용 원칙

- 인용(citation)을 반드시 보존하고, 최종 결과에 출처를 명시한다.
- 스크립트 출력은 JSON이다. `jq`로 필요한 필드만 추출하면 컨텍스트를 절약할 수 있다.
- WebSearch(내장)는 단순 사실 확인(날짜, 이름)에만 사용한다. 조사에는 쓰지 않는다.
- WebFetch는 Haiku 요약 + 125자 인용 제한이 있으므로, 원문이 필요하면 `tavily extract`를 사용한다.

### 서브에이전트 검색 지침 템플릿

서브에이전트 프롬프트에 아래를 포함한다:

```
검색이 필요하면 `./scripts/search.sh`를 사용하라.
- 종합 파악: `./scripts/search.sh perplexity search "query"` (개념 정리)
- 구체적 탐색: `./scripts/search.sh tavily search "query" --depth advanced` (프로젝트/URL 발견)
- 원문 검증: `./scripts/search.sh tavily extract "url"` (핵심 수치/주장의 1차 출처 확인)
- 심층 탐구: `./scripts/search.sh perplexity research "query"` (일반 검색으로 부족할 때만)
Perplexity와 Tavily를 섞어 쓰고, 핵심 결론의 근거는 반드시 원문으로 확인하라.
```

### 비용 참고

| 도구 | 단가 | 참고 |
| --- | --- | --- |
| Perplexity sonar-pro | ~$0.01/요청 | 가성비 최고 |
| Tavily search (advanced) | 2 크레딧 | 월 1,000 크레딧 무료 |
| Tavily extract | 1 크레딧/URL | |
| Tavily research | 5 크레딧 | 비싸지만 필요할 때는 써야 한다 |
| WebSearch (내장) | ~$0.145/요청 | 조사용으로는 비효율 |

비용 인식은 낭비를 피하기 위한 것이지, 필요한 도구 사용을 억제하기 위한 것이 아니다.