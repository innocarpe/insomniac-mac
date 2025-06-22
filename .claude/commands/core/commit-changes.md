# 변경사항 커밋

**반드시 변경사항을 Atomic 한 단위로 작게 나누어 커밋해야 합니다.**

Git 커밋 메시지를 일관성 있게 작성하기 위한 Conventional Commits 스타일 규칙

## **멀티라인 커밋 구현 방법**

### **⚠️ 중요: 단일 -m 옵션으로 모든 내용 압축 금지**
### **⚠️ 중요: HEREDOC 방식으로 커밋할 것**

```bash
# ❌ 절대 금지: 모든 내용을 하나의 -m에 압축
git commit -m "feat(api): analytics API 및 목 데이터 구조 개선 - 새로운 analytics API 모듈 추가, 기존 API 구조 개선, 고급 분석을 위한 목 데이터 확장"

# ✅ 필수: 여러 -m 옵션으로 구조화
git commit -m "feat(api): analytics API 및 목 데이터 구조 개선" \
           -m "" \
           -m "새로운 analytics API 모듈을 추가했습니다:" \
           -m "- 기존 API 구조 개선" \
           -m "- 고급 분석을 위한 목 데이터 확장" \
           -m "- 타입 안전성 향상" \
           -m "" \
           -m "Closes #123"
```

## **기본 형식**

**형식**: `<type>(<scope>): <description>`

**예시**:
- `feat(backend): 새로운 거래 API 추가`
- `fix(frontend): 로그인 버튼 클릭 오류 수정`
- `docs(cursor): API 설계 규칙 문서 개선`

## **커밋 타입 (Type)**

### **주요 타입**
- **`feat`**: 새로운 기능 추가
- **`fix`**: 버그 수정
- **`docs`**: 문서 변경
- **`style`**: 코드 포맷팅, 세미콜론 누락 등 (기능 변경 없음)
- **`refactor`**: 코드 리팩토링 (기능 변경 없음)
- **`perf`**: 성능 개선
- **`test`**: 테스트 추가 또는 수정
- **`chore`**: 빌드 프로세스, 도구 설정 등
- **`security`**: 보안 관련 수정
- **`ai`**: 바이브 코딩 개선을 위한 작업 (Claude Code, Cursor 등)
- **`prd`**: 프로젝트 기획 문서 업데이트나, Task 진행상황 업데이트 등
- **`wip`**: 작업 중인 커밋 (나중에 squash 예정)

### **타입 선택 가이드**
```typescript
// ✅ DO: 명확한 타입 사용
feat(api): 사용자 인증 엔드포인트 추가
fix(trading): 포지션 계산 오류 수정
docs(readme): 설치 가이드 업데이트

// ❌ DON'T: 모호한 타입 사용
update: 코드 수정
change: 파일 변경
```

## **스코프 (Scope)**

### **주요 영역 스코프**
- **`app`**: 앱 전체 설정 및 진입점 (main.swift, AppDelegate)
- **`ui`**: 상태바 UI 및 메뉴 관련 (StatusBarController)
- **`power`**: 전원 관리 및 카페인 모드 (PowerManager)
- **`core`**: 핵심 비즈니스 로직

### **인프라/배포 스코프**
- **`build`**: 빌드 및 앱 번들 생성
- **`ci`**: GitHub Actions, CI/CD 파이프라인
- **`release`**: 릴리스 및 배포 관련

### **개발 도구/설정 스코프**
- **`spm`**: Swift Package Manager 설정 (Package.swift)
- **`config`**: 각종 설정 파일들 (Info.plist 등)
- **`deps`**: 의존성 관리

### **문서/관리 스코프**
- **`docs`**: 문서 작업 (README, PRD, 가이드)
- **`scripts`**: 스크립트 및 자동화 도구
- **`claude`**: Claude 관련 설정 및 문서

### **특화 영역 스코프**
- **`timer`**: 타이머 기능 관련
- **`icon`**: 아이콘 생성 및 관리
- **`startup`**: 시작 시 실행 기능 (LaunchAtLogin)
- **`auth`**: 권한 및 sudoers 설정
- **`notif`**: 알림 관련 기능

### **리뷰/임시 작업 스코프**
- **`review`**: 코드 리뷰 피드백 반영
- **`hotfix`**: 긴급 수정사항
- **`release`**: 릴리스 관련 작업

## **스코프 선택 가이드**

### **스코프 우선순위**
```bash
# 1순위: 기능별 스코프 (더 구체적) ✅ 권장
feat(timer): 30분 타이머 옵션 추가
fix(power): pmset 명령어 실행 오류 수정
refactor(ui): 메뉴 업데이트 로직 개선

# 2순위: 영역별 스코프 (기능 스코프가 애매할 때)
feat(app): 새로운 설정 기능 추가  # ⚠️ 너무 광범위
fix(core): 상태 관리 오류 수정
```

### **파일 경로 기반 매핑**
```bash
# ✅ DO: 파일 경로에 따른 스코프 선택
Sources/Caffeine/main.swift, AppDelegate.swift → app
Sources/Caffeine/StatusBarController.swift → ui
Sources/Caffeine/PowerManager.swift → power
Sources/Caffeine/LaunchAtLogin.swift → startup
.claude/ → claude
.github/workflows/ → ci
Package.swift → spm
README.md, docs/ → docs
scripts/ → scripts
Info.plist → config
```

### **기능 기반 매핑**
```bash
# ✅ DO: 기능에 따른 스코프 선택
전원 관리/카페인 모드 → power
타이머 기능 → timer
상태바/메뉴 UI → ui
시작 시 실행 → startup
권한/sudoers → auth
아이콘 관련 → icon
알림 기능 → notif
```

### **스코프 생략 가능한 경우**
- **전체 프로젝트에 영향을 주는 변경사항**
- **여러 영역에 걸친 광범위한 변경**
- **예시**: `feat: 프로젝트 초기 설정`

## **언어 사용 가이드라인**

### **한국어 커밋 메시지**
```bash
# ✅ DO: 자연스러운 한국어
feat(timer): 카페인 타이머 기능 추가
fix(ui): 메뉴바 아이콘 위치 오류 수정
docs(setup): 비밀번호 없이 사용 설정 가이드 추가
refactor(power): pmset 명령어 실행 로직 개선

# ✅ DO: 기술 용어는 영어 그대로 사용
feat(auth): sudoers 파일 자동 설정 구현
fix(ui): NSMenuDelegate 실시간 업데이트 수정

# ❌ DON'T: 한국어와 영어 혼용
feat(auth): add JWT 토큰 validation
fix(ui): 버튼 click issue 수정
```

## **브랜치별 커밋 컨벤션**

### **Feature 브랜치**
```bash
# 기능 개발 커밋
feat(timer): 카페인 타이머 기능 구현
wip(ui): 메뉴 실시간 업데이트 작업 중
test(power): pmset 명령어 실행 테스트 추가

# 최종 정리 커밋
feat(timer): 카페인 자동 종료 타이머 완성 (#123)
```

### **Hotfix 브랜치**
```bash
# 긴급 수정
fix(hotfix): 거래 중단 오류 긴급 수정
security(hotfix): 인증 우회 취약점 수정
```

### **Release 브랜치**
```bash
# 릴리스 준비
chore(release): v1.2.0 릴리스 준비
docs(release): v1.2.0 변경사항 문서 업데이트
fix(release): 릴리스 전 최종 버그 수정
```

## **이슈/PR 연동 규칙**

### **Footer를 활용한 상세 참조**
```bash
feat(api): 사용자 인증 엔드포인트 추가

사용자 등록 및 로그인 기능을 위한 REST API를 구현했습니다.
- JWT 토큰 기반 인증
- 비밀번호 암호화
- 세션 관리

Resolves: #123
See also: #456, #789
Co-authored-by: 개발자명 <email@example.com>
```

## **커밋 메시지 예시**

### **Core 기능 관련**
```bash
# ✅ DO: 명확한 기능 커밋
feat(power): 카페인 모드 토글 기능 추가
feat(timer): 30분~6시간 타이머 옵션 구현
fix(power): pmset 권한 오류 수정
refactor(ui): 메뉴 업데이트 로직 개선
perf(ui): 타이머 실시간 업데이트 성능 최적화
security(auth): sudoers 설정 보안 강화

# ❌ DON'T: 모호한 커밋
feat: 기능 추가
fix: 버그 수정
refactor: 코드 정리
```

### **UI/UX 관련**
```bash
# ✅ DO: 명확한 UI 커밋
feat(ui): 카페인 타이머 메뉴 추가
feat(ui): 실시간 타이머 카운트다운 표시
fix(ui): 메뉴바 아이콘 위치 정렬 수정
style(ui): SF Symbols 아이콘 적용
test(ui): StatusBarController 단위 테스트 추가
refactor(ui): 메뉴 빌드 로직 최적화

# ❌ DON'T: 모호한 UI 커밋
feat: UI 추가
style: 디자인 수정
refactor: 구조 개선
```

### **개발 도구/설정**
```bash
# ✅ DO: 명확한 도구/설정 커밋
docs(claude): 프로젝트 개발 가이드 개선
chore(spm): Swift Package 의존성 업데이트
chore(deps): macOS 최소 버전 12.0으로 설정
feat(scripts): 앱 번들 생성 스크립트 추가
ci: GitHub Actions 워크플로우 추가
feat(icon): 실제감 있는 커피잔 아이콘 생성

# ❌ DON'T: 모호한 도구/설정 커밋
docs: 문서 수정
chore: 설정 변경
chore: 의존성 업데이트
```

### **빌드/배포**
```bash
# ✅ DO: 명확한 빌드/배포 커밋
feat(build): 앱 번들 자동 생성 스크립트 추가
ci: Swift 빌드 및 테스트 자동화 구현
chore(release): v2.0.0 릴리스 준비
security(config): Info.plist 권한 설정 강화
feat(scripts): 아이콘 생성 자동화 추가

# ❌ DON'T: 모호한 빌드 커밋
feat: 빌드 추가
chore: 스크립트 수정
ci: 워크플로우 수정
```

### **리팩토링 상황별**
```bash
# ✅ DO: 리팩토링 목적 명시
refactor(power): PowerManager 클래스 구조 개선
refactor(ui): 메뉴 업데이트 로직 재사용성 향상
refactor(timer): 타이머 관리 로직 모듈화
refactor(auth): sudoers 설정 로직 단순화

# ❌ DON'T: 모호한 리팩토링
refactor: 코드 정리
refactor: 구조 개선
refactor: 최적화
```

### **리뷰 반영 커밋**
```bash
# ✅ DO: 리뷰 피드백 반영
fix(review): 코드 리뷰 피드백 반영 - 변수명 개선
style(review): 코딩 컨벤션 적용 - 들여쓰기 수정
refactor(review): 메서드 분리 및 주석 추가
security(review): 보안 리뷰 피드백 반영 - 입력값 검증 강화
```

### **WIP 및 임시 커밋**
```bash
# 작업 중인 커밋 (나중에 squash)
wip(ui): 타이머 메뉴 UI 작업 중
wip(power): sudoers 설정 로직 구현 진행중
wip(timer): 실시간 업데이트 로직 개발 중

# 최종 커밋으로 정리 후
feat(timer): 카페인 자동 종료 타이머 구현

자동 종료 타이머 시스템을 구현했습니다.
- 30분~6시간 타이머 옵션
- 실시간 카운트다운 표시
- 타이머 만료 시 알림
- OFF 상태에서도 타이머 설정 가능

Closes #123
```

## **커밋 메시지 작성 체크리스트**

### **필수 확인사항**
1. ✅ **타입이 명확한가?** (feat, fix, docs, etc.)
2. ✅ **스코프가 적절한가?** (기능별 → 영역별 순서로 선택)
3. ✅ **설명이 구체적인가?** (무엇을 했는지 명확히)
4. ✅ **현재형으로 작성했는가?** ("추가한다" 아닌 "추가")
5. ✅ **50자 이내로 작성했는가?** (제목 길이 제한)
6. ✅ **언어 일관성을 유지했는가?** (한국어 또는 영어 일관 사용)
7. ✅ **이슈 번호를 포함했는가?** (해당되는 경우)

### **좋은 커밋 메시지 특징**
- **명확성**: 무엇을 변경했는지 즉시 이해 가능
- **일관성**: 프로젝트 전체에서 동일한 형식 사용
- **간결성**: 불필요한 단어 제거
- **구체성**: 추상적인 표현 대신 구체적인 내용
- **추적성**: 이슈나 요구사항과 연결

### **피해야 할 커밋 메시지**
```bash
# ❌ DON'T: 모호한 메시지
fix: 버그 수정
update: 코드 업데이트
change: 파일 변경
refactor: 리팩토링
style: 스타일 수정

# ❌ DON'T: 너무 긴 메시지
feat(backend): 사용자 인증 시스템을 구현하고 JWT 토큰 기반 인증을 추가하며 비밀번호 암호화 기능도 함께 구현

# ❌ DON'T: 과거형 사용
feat(api): 사용자 API를 추가했음
fix(ui): 버튼 오류를 수정했음

# ❌ DON'T: 언어 혼용
feat(auth): add JWT 토큰 validation
fix(ui): 버튼 click issue 수정
```

## **Breaking Changes**

### **Breaking Change 표시**
```bash
# ✅ DO: Breaking change 명시
feat(api)!: 사용자 인증 API 구조 변경 (#123)

# 또는 본문에 BREAKING CHANGE 추가
feat(api): 사용자 인증 API 개선

BREAKING CHANGE: 기존 /auth 엔드포인트가 /api/auth로 변경됨
마이그레이션 가이드: docs/migration-v2.md 참조

Closes #123
```

### **Breaking Change 가이드라인**
- **!** 기호를 타입/스코프 뒤에 추가
- **본문에 BREAKING CHANGE 설명 추가**
- **마이그레이션 가이드 제공**
- **영향 범위 명시**

## **커밋 히스토리 관리**

### **Squash 가이드라인**
```bash
# Feature 브랜치의 여러 커밋을 하나로 정리
git rebase -i HEAD~3

# 최종 커밋 메시지 예시
feat(trading): 자동 거래 시스템 구현

완전한 자동 거래 시스템을 구현했습니다.
- RSI 기반 매매 신호 생성 로직
- 포지션 크기 계산 알고리즘
- 리스크 관리 및 손절매 로직
- 백테스팅 결과 검증 기능
- 실시간 모니터링 대시보드

Performance: 1초당 1000건의 신호 처리 가능
Testing: 95% 코드 커버리지 달성

Closes #123, #124
Co-authored-by: 팀원명 <email@example.com>
```

### **커밋 분할 가이드**
```bash
# ❌ DON'T: 너무 많은 변경사항을 하나의 커밋에
feat(system): 전체 시스템 구현

# ✅ DO: 논리적 단위로 커밋 분할
feat(auth): 사용자 인증 시스템 구현
feat(trading): 거래 로직 구현
feat(ui): 대시보드 UI 구현
test(system): 통합 테스트 추가
```

## **커밋 메시지 템플릿**

### **기본 템플릿**
```
<type>(<scope>): <description> (#issue)

[optional body]

[optional footer(s)]
```

### **상세 템플릿 예시**
```
feat(timer): 카페인 자동 종료 타이머 추가 (#123)

카페인 모드 자동 종료 타이머를 구현했습니다.
- 30분부터 6시간까지 7개 옵션 제공
- 실시간 초 단위 카운트다운 표시
- OFF 상태에서 타이머 설정 시 자동 ON
- 타이머 만료 시 시스템 알림

Performance: RunLoop.common 모드로 실시간 업데이트
Testing: 타이머 기능 단위 테스트 추가

Closes #123
See also: #124 (백테스팅 개선)
```

### **간단한 템플릿**
```
feat(scope): 기능 추가 (#123)
fix(scope): 오류 수정 (#456)
docs(scope): 문서 업데이트
refactor(scope): 코드 개선
```
