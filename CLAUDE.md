# Caffeine - macOS 메뉴바 앱

**중요사항**
사용자와는 항상 한국어로 소통할 것.

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참고할 가이드라인을 제공합니다.

## ⚠️ 주의사항

- **커밋 메시지는 항상 한국어로 작성할 것**
- **모든 파일은 마지막에 반드시 하나의 개행 문자로 끝날 것**
- **파일 생성 전 기존 파일에 추가/수정 가능한지 먼저 검토할 것**

## 프로젝트 개요

Caffeine은 macOS에서 Mac이 잠자기 모드로 들어가는 것을 방지하는 메뉴바 애플리케이션입니다. 클릭 한 번으로 카페인 모드를 켜고 끌 수 있으며, 자동 종료 타이머와 비밀번호 없이 사용할 수 있는 기능을 제공합니다.

## 현재 구현 상태

✅ **버전 2.0.0** - 모든 기능 구현 및 테스트 완료
- 카페인 모드 토글 기능 (클릭으로 ON/OFF)
- 자동 종료 타이머 (30분~6시간, 실시간 카운트다운)
- 비밀번호 없이 사용 (sudoers 설정)
- 시작 시 자동 실행
- 커스텀 앱 아이콘 및 SF Symbols 메뉴바 아이콘
- 첫 실행 시 자동 설정 다이얼로그
- macOS 12.0 이상 지원

## 프로젝트 구조

```
Caffeine/
├── Package.swift                    # Swift Package Manager 설정
├── Sources/
│   └── Caffeine/
│       ├── main.swift              # 앱 진입점
│       ├── AppDelegate.swift       # 앱 생명주기 및 초기 설정
│       ├── StatusBarController.swift # 상태바 UI 및 사용자 상호작용
│       ├── PowerManager.swift      # 전원 관리 및 타이머 로직
│       ├── LaunchAtLogin.swift     # 시작 시 실행 관리
│       └── Resources/
│           └── Info.plist          # 앱 메타데이터
├── scripts/
│   ├── create-app.sh              # 앱 번들 생성 스크립트
│   ├── create-realistic-icon.swift # 앱 아이콘 생성
│   └── setup-passwordless.sh      # sudoers 설정
├── docs/
│   ├── PRD.md                     # 제품 요구사항 문서
│   ├── PASSWORDLESS_SETUP.md      # 설정 문서
│   └── ICON_ADJUSTMENT.md         # 아이콘 위치 조정 노트
├── README.md                      # 사용자 문서
├── CLAUDE.md                      # 이 파일
└── Caffeine.app/                  # 빌드된 애플리케이션 번들
```

## 주요 컴포넌트 및 기능

### AppDelegate
- 앱 초기화 및 생명주기 관리
- 첫 실행 시 비밀번호 설정 다이얼로그 구현
- 타이머 알림을 위한 알림 권한 요청
- 비밀번호 없이 사용하기 위한 sudoers 자동 설정

### StatusBarController
- 메뉴바 아이콘 및 메뉴 관리
- 실시간 타이머 업데이트를 위한 NSMenuDelegate 구현
- 모든 사용자 상호작용 처리 (클릭, 메뉴 선택)
- 주요 기능:
  - RunLoop.main의 .common 모드를 사용한 실시간 타이머 카운트다운
  - 상태에 따른 동적 메뉴 재구성
  - 타이머 표시 형식: "N시간 N분 N초 후 꺼짐"

### PowerManager
- pmset 명령어를 통한 잠자기 제어
- 타이머 상태 및 카운트다운 관리
- sudo 및 AppleScript 실행 지원
- OFF 상태에서 타이머 설정 시 자동으로 카페인 모드 활성화
- UserDefaults를 통한 상태 영속성

### 타이머 구현
- 7개 프리셋 옵션: 30분, 1시간, 2시간, 3시간, 4시간, 5시간, 6시간
- 초 단위 정밀도의 실시간 카운트다운
- ON/OFF 상태 모두에서 작동
- 타이머 완료 시 시스템 알림
- 메뉴가 열려있는 동안 실시간 업데이트

## 빌드 및 설치

### 소스에서 빌드
```bash
# 저장소 클론
git clone <repository-url>
cd Caffeine

# 릴리스 버전 빌드
swift build -c release

# 앱 번들 생성 (아이콘 생성 포함)
./scripts/create-app.sh

# Applications 폴더로 이동
mv Caffeine.app /Applications/
```

### 첫 실행
1. Caffeine.app을 우클릭 → 열기 (Gatekeeper 우회)
2. 설정 다이얼로그가 자동으로 나타남
3. "설정하기" 클릭 후 관리자 비밀번호 한 번 입력
4. 이후부터는 비밀번호 없이 사용 가능

## 기술적 구현 세부사항

### 비밀번호 없이 사용
- pmset 권한을 위한 `/etc/sudoers.d/caffeine` 생성
- 관리자 사용자가 비밀번호 없이 pmset -b disablesleep 실행 가능
- 필요시 관리자 권한의 AppleScript로 폴백

### 실시간 타이머 업데이트
```swift
// StatusBarController의 핵심 구현
private func startMenuUpdateTimer() {
    menuUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.updateTimerDisplay()
    }
    if let timer = menuUpdateTimer {
        RunLoop.main.add(timer, forMode: .common)
    }
}
```

### 메뉴 구조
- 타이머 상태 (활성화 시)
- 구분선
- "카페인 모드 켜기/끄기"
- "카페인 타이머" → 시간 옵션 서브메뉴
- 구분선
- "시작 시 실행" (체크박스)
- "정보"
- 구분선
- "종료"

## 사용자 경험 흐름

1. **첫 실행**: 자동 설정 다이얼로그 → 관리자 비밀번호 → sudoers 설정 완료
2. **일반 사용**: 아이콘 클릭으로 토글, 우클릭으로 메뉴 표시
3. **타이머 사용**: 
   - OFF 상태에서: 타이머 선택 → 자동으로 카페인 활성화 → 카운트다운 시작
   - ON 상태에서: 타이머 선택 → 카운트다운 시작 → 완료 시 자동 비활성화
4. **시각적 피드백**: 아이콘 변경, 툴팁 업데이트, 타이머 초 단위 표시

## 테스트 체크리스트
- [x] 기본 토글 기능
- [x] OFF 상태에서 타이머 (자동 활성화)
- [x] ON 상태에서 타이머
- [x] 실시간 카운트다운 표시
- [x] 타이머 취소
- [x] 시작 시 실행
- [x] 비밀번호 없이 사용
- [x] 앱 아이콘 표시
- [x] 다크/라이트 모드 호환성
- [x] 타이머 완료 시 알림
- [x] 맥북 덮기 테스트 (활성화 시 잠들지 않음)

## 버전 히스토리
- **1.0.0**: 기본 토글 기능 초기 릴리스
- **1.1.0**: 타이머 기능 추가
- **1.2.0**: 비밀번호 없이 사용 구현
- **2.0.0**: 모든 기능 완성된 최종 릴리스

---

**최종 업데이트**: 2025-06-22  
**상태**: 완료 - 모든 기능 구현 및 테스트 완료