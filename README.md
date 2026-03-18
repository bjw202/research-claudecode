# Research with Claude Code

Claude Code의 `CLAUDE.md` 프로젝트 인스트럭션과 멀티에이전트 아키텍처를 활용한 딥리서치 프레임워크.

## 개요

복잡한 리서치 주제를 Claude Code에게 요청하면, 메인 에이전트가 서브 에이전트들(Researcher, Critic, Verifier, Synthesizer, Journal)을 조직하여 **다관점 조사 → 검증 → 통합**을 자동으로 수행한다. 결과물은 마크다운 파일로 축적되어 재활용 가능하다.

## 프로젝트 구조

```
.
├── CLAUDE.md                  # 핵심: 리서치 정책·에이전트 규칙·검색 전략 정의
├── scripts/
│   └── search.sh              # Perplexity / Tavily API 래퍼 스크립트
├── .env.sample                # API 키 템플릿
├── .claude/
│   └── skills/
│       └── push/SKILL.md      # GitHub 푸시 스킬
└── docs/                      # (리서치 시 자동 생성)
    ├── research/
    │   └── {YYYY-MM-DD}-{topic}/   # 리서치별 산출물 폴더
    └── dev-journal/
        └── {YYYY-MM-DD}-{project}.md  # 세션 저널
```

## 설치 및 설정

### 1. 저장소 클론

```bash
git clone <repo-url>
cd research-claudecode
```

### 2. API 키 설정

```bash
cp .env.sample .env
```

`.env` 파일에 API 키를 입력한다:

```
PERPLEXITY_API_KEY="your-perplexity-api-key"
TAVILY_API_KEY="your-tavily-api-key"
```

- **Perplexity API**: https://docs.perplexity.ai/ 에서 발급
- **Tavily API**: https://tavily.com/ 에서 발급 (월 1,000 크레딧 무료)

### 3. 의존성

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 설치 필요
- `curl`, `jq` — 검색 스크립트가 사용 (macOS 기본 포함 또는 `brew install jq`)

### 4. 실행 권한

```bash
chmod +x scripts/search.sh
```

## 사용법

### 리서치 실행

프로젝트 디렉토리에서 Claude Code를 실행하고 리서치 주제를 요청한다:

```bash
claude
```

```
> ML 기반 주식 돌파 패턴 예측의 실효성을 조사해줘
> 아노다이징 공정의 품질 지표 체계를 리서치해줘
```

CLAUDE.md의 정책에 따라 자동으로:
1. 리서치 폴더 생성 (`docs/research/YYYY-MM-DD-topic/`)
2. 서브 에이전트 분배 (Researcher, Critic, Verifier 등)
3. 검색 → 검증 → 통합 수행
4. 저널 기록 (`docs/dev-journal/`)

### 검색 스크립트 직접 사용

```bash
# 종합 파악 (Perplexity)
./scripts/search.sh perplexity search "query"

# 구체적 탐색 (Tavily)
./scripts/search.sh tavily search "query" --depth advanced

# 원문 추출
./scripts/search.sh tavily extract "https://example.com/article"

# 심층 조사
./scripts/search.sh perplexity research "query"
./scripts/search.sh perplexity reason "complex comparison query"
./scripts/search.sh tavily research "query"
```

## 핵심 정책 요약

`CLAUDE.md`에 정의된 주요 정책:

| 정책 | 설명 |
|------|------|
| **Multi-Agent Research** | 메인은 조직·통합만, 실제 조사는 서브 에이전트가 수행 |
| **Design-First** | 구현 전 설계 논의 필수 |
| **Requirement Validation** | 요청을 그대로 실행하지 않고 최선의 문제 정의인지 검토 |
| **Final Integration** | 서브 에이전트 결과를 검증·통합 후 판단으로 제시 |
| **Journal** | 의미 있는 세션마다 의사결정 로그 기록 |
| **Search Flow** | 얕은 검색 → 원문 검증 → 심층 탐구 (단계적 심화) |

## 커스터마이징

- **리서치 정책 변경**: `CLAUDE.md`를 직접 수정
- **검색 제공자 추가**: `scripts/search.sh`에 새 provider 함수 추가
- **스킬 추가**: `.claude/skills/` 하위에 `SKILL.md` 작성

## 비용 참고

| 도구 | 단가 |
|------|------|
| Perplexity sonar-pro | ~$0.01/요청 |
| Tavily search (advanced) | 2 크레딧 |
| Tavily extract | 1 크레딧/URL |
| Tavily research | 5 크레딧 |

## License

MIT
