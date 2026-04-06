# Insomniac - macOS 메뉴바 앱

**중요사항**
사용자와는 항상 한국어로 소통할 것.

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참고할 가이드라인을 제공합니다.

## ⚠️ 주의사항

- **커밋 메시지는 항상 한국어로 작성할 것**
- **모든 파일은 마지막에 반드시 하나의 개행 문자로 끝날 것**
- **파일 생성 전 기존 파일에 추가/수정 가능한지 먼저 검토할 것**

## 프로젝트 개요

Insomniac은 macOS에서 Mac이 잠자기 모드로 들어가는 것을 방지하는 메뉴바 애플리케이션입니다. 클릭 한 번으로 카페인 모드를 켜고 끌 수 있으며, 자동 종료 타이머 기능을 제공합니다.

## 앱 빌드 및 설치

사용자가 "앱 만들어 줘", "빌드해 줘", "설치해 줘" 등을 요청하면 다음 명령을 실행:

```bash
# 1. 릴리스 빌드
swift build -c release

# 2. 앱 번들 생성 (아이콘 포함, 코드 서명)
bash scripts/create-app.sh

# 3. /Applications에 설치
pkill -f Insomniac 2>/dev/null; sleep 1
rm -rf /Applications/Insomniac.app
cp -R Insomniac.app /Applications/
rm -rf Insomniac.app

# 4. 실행
open /Applications/Insomniac.app
```

### create-app.sh 역할
1. `swift build -c release`로 빌드된 바이너리를 `.app` 번들로 패키징
2. `Info.plist` 생성 (번들 ID, LSUIElement 등)
3. `resources/AppIcon.icns`에서 앱 아이콘 복사
4. ad-hoc 코드 서명 적용

## 프로젝트 구조

```
Insomniac/
├── Package.swift                    # Swift Package Manager 설정
├── Sources/
│   └── Insomniac/
│       ├── main.swift              # 앱 진입점
│       ├── AppDelegate.swift       # 앱 생명주기 관리
│       ├── StatusBarController.swift # 상태바 UI 및 사용자 상호작용
│       ├── PowerManagerProtocol.swift # 전원 관리 인터페이스
│       ├── PowerManagerImpl.swift  # IOPMAssertion 기반 전원 관리
│       ├── LaunchAtLogin.swift     # 시작 시 실행 관리
│       └── Resources/
│           └── Info.plist          # 앱 메타데이터
├── resources/
│   └── AppIcon.icns               # 앱 아이콘 (tea cup)
├── scripts/
│   ├── create-app.sh              # 앱 번들 생성 스크립트
│   ├── create-dmg.sh              # DMG 설치 파일 생성
│   └── create-realistic-icon.swift # 아이콘 생성 (폴백용)
├── Tests/
│   └── InsomniacTests/
├── CLAUDE.md                      # 이 파일
└── README.md                      # 사용자 문서
```

## 주요 컴포넌트 및 기능

### 의존성 주입 및 테스트 가능한 설계
- **프로토콜 기반 설계**: 인터페이스는 원래 이름 사용 (예: PowerManager)
- **구현체 네이밍**: 구현체는 Impl postfix 사용 (예: PowerManagerImpl)
- **의존성 주입**: 생성자를 통한 의존성 주입으로 테스트 용이성 확보
- **Mock 객체**: 프로토콜 기반으로 쉽게 Mock 객체 생성 가능

### AppDelegate
- 앱 초기화 및 생명주기 관리
- 알림 권한 요청 (번들 ID 확인 후)
- 시스템 종료/재시작 시 카페인 모드 해제

### StatusBarController
- 메뉴바 아이콘 및 메뉴 관리 (SF Symbols: cup.and.saucer)
- 좌클릭으로 토글, 우클릭으로 메뉴 표시
- 실시간 타이머 카운트다운 (NSMenuDelegate)

### PowerManager (IOPMAssertion 기반)
- `IOPMAssertionCreateWithName`으로 잠자기 방지 (sudo 불필요)
- 앱 종료 시 assertion 자동 해제
- 타이머 만료 시 덮개 닫힘 감지 후 즉시 잠자기

### 타이머 구현
- 9개 프리셋 옵션: 5분, 10분, 30분, 1시간, 2시간, 3시간, 4시간, 5시간, 6시간
- 초 단위 정밀도의 실시간 카운트다운
- 타이머 완료 시 시스템 알림

## 버전 히스토리
- **1.0.0**: 기본 토글 기능 초기 릴리스
- **1.1.0**: 타이머 기능 추가
- **1.2.0**: 비밀번호 없이 사용 구현 (sudoers)
- **2.0.0**: 모든 기능 완성
- **3.0.0**: IOPMAssertion API 전환, macOS Tahoe 호환, 앱 이름 Insomniac으로 변경

---

**최종 업데이트**: 2026-04-06
**상태**: 완료 - macOS Tahoe 호환
