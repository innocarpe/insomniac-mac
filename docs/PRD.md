# Caffeine - macOS 상태바 슬립 방지 앱 PRD

## 1. 프로젝트 개요

### 1.1 제품명
**Caffeine** - macOS Sleep Prevention Menu Bar App

### 1.2 제품 설명
Caffeine은 macOS 상태바에 상주하는 간단한 유틸리티 앱으로, 클릭 한 번으로 Mac이 자동으로 잠자기 모드에 들어가는 것을 방지하거나 허용할 수 있습니다. 맥북을 덮어도 시스템이 계속 작동하도록 유지할 수 있어, 대용량 파일 다운로드, 백업 작업, 원격 접속 등의 상황에서 유용합니다.

### 1.3 대상 사용자
- 개인 사용 (단일 사용자)
- macOS Monterey 12.0 이상 사용자

## 2. 목적 및 배경

### 2.1 문제 정의
- 현재 터미널에서 `sudo pmset -b disablesleep` 명령어를 수동으로 입력해야 함
- 현재 카페인 모드 상태를 확인하기 어려움
- 매번 터미널을 열고 명령어를 입력하는 것이 번거로움
- sudo 권한이 필요하여 매번 비밀번호를 입력해야 함

### 2.2 솔루션
- 상태바에 상주하는 간단한 GUI 앱 제공
- 클릭 한 번으로 카페인 모드 ON/OFF 토글
- 현재 상태를 아이콘으로 직관적으로 표시
- 타이머 기능으로 자동 종료 지원
- 첫 실행 시 한 번만 권한 설정

## 3. 주요 기능 및 요구사항

### 3.1 핵심 기능

#### 3.1.1 상태바 아이콘
- **위치**: macOS 상단 메뉴바 (시스템 트레이)
- **아이콘 상태**:
  - OFF 상태: 빈 커피잔 아이콘 (`cup.and.saucer`)
  - ON 상태: 채워진 커피잔 아이콘 (`cup.and.saucer.fill`)
- **SF Symbols 사용**: 시스템 테마 자동 적응

#### 3.1.2 토글 기능
- **클릭 동작**: 좌클릭 시 카페인 모드 ON/OFF 토글
- **상태 전환**:
  - OFF → ON: `sudo pmset -b disablesleep 1` 실행
  - ON → OFF: `sudo pmset -b disablesleep 0` 실행
- **즉각적 피드백**: 상태 변경 시 아이콘 즉시 업데이트

#### 3.1.3 메뉴 옵션
- **우클릭 메뉴**:
  - 타이머 상태 표시 (활성화 시 실시간 카운트다운)
  - "카페인 모드 켜기/끄기" (현재 상태에 따라 동적 변경)
  - "카페인 타이머" (서브메뉴)
    - 30분, 1시간, 2시간, 3시간, 4시간, 5시간, 6시간
    - 타이머 취소 (활성화 시)
  - 구분선
  - "시작 시 실행" (체크박스)
  - "정보" (앱 버전 및 기능 설명)
  - 구분선
  - "종료"

### 3.2 추가 기능

#### 3.2.1 비밀번호 없이 사용
- 첫 실행 시 자동으로 설정 안내
- sudoers 설정으로 pmset 명령어만 비밀번호 없이 실행
- 한 번 설정 후 영구적으로 편리하게 사용

#### 3.2.2 카페인 타이머
- **자동 종료**: 설정한 시간 후 카페인 모드 자동 OFF
- **임시 사용**: OFF 상태에서도 타이머 설정 시 자동으로 ON
- **실시간 표시**: 메뉴 상단에 남은 시간 초 단위까지 표시
- **알림**: 타이머 만료 시 시스템 알림

#### 3.2.3 상태 표시
- 툴팁: 마우스 호버 시 현재 상태 텍스트 표시
  - "카페인 모드 OFF - 클릭하여 켜기"
  - "카페인 모드 ON - 클릭하여 끄기"

### 3.3 비기능적 요구사항

#### 3.3.1 성능
- 메모리 사용량: 50MB 이하
- CPU 사용률: 유휴 상태에서 0.1% 이하
- 시작 시간: 1초 이내

#### 3.3.2 호환성
- macOS 12.0 (Monterey) 이상
- Apple Silicon (M1/M2/M3) 및 Intel Mac 지원
- 네이티브 Universal Binary

#### 3.3.3 보안
- 코드 서명 (ad-hoc 서명)
- 최소 권한 원칙 (pmset 명령어만 허용)
- 시스템 무결성 보호(SIP) 준수

## 4. 기술 스택

### 4.1 개발 언어 및 프레임워크
- **언어**: Swift 5.9+
- **UI 프레임워크**: AppKit (메뉴바 앱에 최적화)
- **빌드 시스템**: Swift Package Manager
- **개발 도구**: Xcode 15.0+ 또는 VS Code + Swift Extension

### 4.2 주요 기술
- **권한 관리**: sudoers 설정 + AppleScript
- **시스템 명령**: Process API를 통한 pmset 실행
- **상태 저장**: UserDefaults
- **아이콘**: SF Symbols (cup.and.saucer)
- **타이머**: Timer + RunLoop integration
- **알림**: UserNotifications framework

### 4.3 프로젝트 구조
```
Caffeine/
├── Package.swift                    # Swift Package Manager 설정
├── Sources/
│   └── Caffeine/
│       ├── main.swift              # 앱 진입점
│       ├── AppDelegate.swift       # 앱 초기화 및 권한 설정
│       ├── StatusBarController.swift # 상태바 UI 및 메뉴 관리
│       ├── PowerManager.swift      # 전원 관리 및 타이머 로직
│       ├── LaunchAtLogin.swift     # 시작 시 실행 기능
│       └── Resources/
│           └── Info.plist          # 앱 메타데이터
├── Tests/
│   └── CaffeineTests/             # 단위 테스트
├── docs/
│   ├── PRD.md                     # 제품 요구사항 문서
│   ├── PASSWORDLESS_SETUP.md      # 비밀번호 설정 가이드
│   └── ICON_ADJUSTMENT.md         # 아이콘 조정 가이드
├── scripts/
│   ├── create-app.sh              # 앱 번들 생성
│   ├── create-realistic-icon.swift # 앱 아이콘 생성
│   └── setup-passwordless.sh      # sudoers 설정
└── Caffeine.app/                  # 빌드된 앱 번들
```

## 5. UI/UX 디자인

### 5.1 아이콘 디자인
- **메뉴바 아이콘**: SF Symbols 사용
  - 크기: 시스템 표준
  - 색상: 템플릿 이미지로 시스템 테마 자동 적응
- **앱 아이콘**: 커스텀 커피잔 디자인
  - 현실적인 3D 스타일
  - 갈색 그라데이션 배경
  - 모든 해상도 지원 (16x16 ~ 1024x1024)

### 5.2 인터랙션
- **좌클릭**: 즉시 토글
- **우클릭**: 메뉴 표시
- **메뉴 열림 시**: 타이머 실시간 업데이트 (1초 단위)

### 5.3 메뉴 디자인
- 표준 macOS 컨텍스트 메뉴 스타일
- 타이머 상태는 최상단 표시
- 계층적 서브메뉴 구조

## 6. 시스템 아키텍처

### 6.1 컴포넌트 구조
```
┌─────────────────────────────────────┐
│         main.swift                  │
│  - NSApplication 초기화             │
│  - AppDelegate 설정                 │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│         AppDelegate                 │
│  - 앱 초기화                       │
│  - 권한 설정 확인                  │
│  - 알림 권한 요청                  │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│      StatusBarController            │
│  - 메뉴바 아이콘 관리              │
│  - 메뉴 구성 및 업데이트           │
│  - 사용자 인터랙션 처리            │
│  - NSMenuDelegate 구현             │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│         PowerManager                │
│  - pmset 명령 실행                 │
│  - 카페인 상태 관리                │
│  - 타이머 관리                     │
│  - sudoers 확인                    │
└─────────────────────────────────────┘
```

### 6.2 데이터 플로우
1. 사용자가 상태바 아이콘 클릭
2. StatusBarController가 이벤트 수신
3. PowerManager에 토글/타이머 요청
4. PowerManager가 sudo 또는 AppleScript로 pmset 실행
5. 상태 변경 후 UI 업데이트
6. 타이머 설정 시 Timer 생성 및 RunLoop 등록

## 7. 구현 특징

### 7.1 비밀번호 없이 사용
- 첫 실행 시 자동 감지 및 설정 안내
- sudoers 파일 생성: `/etc/sudoers.d/caffeine`
- 설정 내용: `%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -b disablesleep 0, /usr/bin/pmset -b disablesleep 1`

### 7.2 타이머 실시간 업데이트
- NSMenuDelegate 활용
- RunLoop.main에 Timer 등록 (`.common` 모드)
- 메뉴 열림/닫힘 이벤트 감지

### 7.3 시작 시 실행
- macOS 13+: SMAppService API
- 이전 버전: SMLoginItemSetEnabled

## 8. 테스트 완료 항목

### 8.1 기능 테스트
- ✅ 카페인 모드 ON/OFF 토글
- ✅ 타이머 설정 및 자동 종료
- ✅ OFF 상태에서 타이머로 자동 켜기
- ✅ 실시간 타이머 카운트다운
- ✅ 시작 시 실행 설정
- ✅ 비밀번호 없이 사용 설정

### 8.2 UI 테스트
- ✅ 아이콘 상태 변경
- ✅ 메뉴 동적 업데이트
- ✅ 다크/라이트 모드 전환
- ✅ 타이머 실시간 표시

### 8.3 시스템 테스트
- ✅ 맥북 덮기 테스트 (카페인 ON 시 잠들지 않음)
- ✅ 권한 설정 프로세스
- ✅ 앱 재시작 시 상태 유지

## 9. 빌드 및 배포

### 9.1 빌드 명령어
```bash
# 빌드
swift build -c release

# 앱 번들 생성
./scripts/create-app.sh

# 설치
mv Caffeine.app /Applications/
```

### 9.2 첫 실행
1. 우클릭 → 열기 (Gatekeeper 우회)
2. 권한 설정 다이얼로그
3. 관리자 비밀번호 입력 (한 번만)

## 10. 알려진 제한사항

- 배터리 모드에서만 작동 (`pmset -b`)
- 전원 연결 시에는 별도 설정 필요
- macOS 업데이트 시 sudoers 설정 재확인 필요

## 11. 향후 개선 계획

### 11.1 단기
- ✅ 타이머 기능 (완료)
- ✅ 비밀번호 없이 사용 (완료)
- ⏳ 키보드 단축키 지원
- ⏳ 전원 모드별 개별 설정

### 11.2 장기
- 사용 통계 대시보드
- 스케줄 기반 자동화
- 특정 앱 실행 시 자동 활성화

---

**문서 버전**: 2.0.0  
**최종 수정일**: 2025-06-22  
**작성자**: Caffeine Development Team