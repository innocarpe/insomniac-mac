# Insomniac

macOS에서 Mac이 잠자기 모드로 들어가는 것을 방지하는 메뉴바 앱입니다.

맥북 덮개를 닫아도 Mac이 깨어있도록 하고, 원하는 시간 후 자동으로 꺼지는 타이머 기능을 제공합니다.

## 주요 기능

- 클릭 한 번으로 잠자기 방지 ON/OFF
- 맥북 덮개를 닫아도 동작
- 자동 꺼짐 타이머 (5분 ~ 6시간)
- 실시간 타이머 카운트다운 표시
- 시작 시 자동 실행 옵션
- 다크/라이트 모드 지원
- 관리자 비밀번호 불필요 (IOPMAssertion API 사용)

## 요구사항

- macOS 12.0 (Monterey) 이상
- Swift 5.9 이상 (빌드 시)

## 설치

### 소스에서 빌드

```bash
git clone https://github.com/innocarpe/insomniac-mac.git
cd insomniac-mac

# 릴리스 빌드
swift build -c release

# 앱 번들 생성 (아이콘 포함, 코드 서명)
./scripts/create-app.sh

# Applications 폴더로 이동
mv Insomniac.app /Applications/
```

### 첫 실행

1. Applications 폴더에서 `Insomniac.app`을 **우클릭 → 열기**
2. 보안 다이얼로그에서 "열기" 클릭
3. 메뉴바에 찻잔 아이콘이 나타나면 완료

## 사용법

- **좌클릭**: 카페인 모드 토글 (ON/OFF)
- **우클릭**: 메뉴 표시
  - 카페인 모드 켜기/끄기
  - 카페인 타이머 (5분, 10분, 30분, 1시간, 2시간, 3시간, 4시간, 5시간, 6시간)
  - 시작 시 실행
  - 정보
  - 종료

### 타이머

- **OFF 상태에서 타이머 설정**: 자동으로 카페인 모드 ON → 설정 시간 후 OFF
- **ON 상태에서 타이머 설정**: 설정 시간 후 카페인 모드 OFF
- 메뉴를 열면 남은 시간이 실시간으로 표시됩니다

## 동작 원리

IOPMAssertion API를 사용하여 시스템 잠자기를 방지합니다.

- sudo/관리자 권한이 필요 없습니다
- 앱 종료 시 assertion이 자동 해제되어 안전합니다
- 타이머 만료 시 맥북 덮개가 닫혀있으면 즉시 잠자기 모드로 전환합니다

## 개발

```bash
# 빌드
swift build

# 테스트
swift test

# 앱 번들 생성
./scripts/create-app.sh

# DMG 설치 파일 생성
./scripts/create-dmg.sh
```

개발 가이드라인은 [CLAUDE.md](CLAUDE.md)를 참고하세요.

## 트러블슈팅

- **앱이 열리지 않음**: 더블클릭 대신 우클릭 → "열기" 선택
- **메뉴바에 아이콘이 안 보임**: 시스템 설정 → 메뉴 막대에서 Insomniac이 허용되어 있는지 확인. Bartender 같은 메뉴바 관리 앱이 숨기고 있을 수 있습니다.
- **macOS Tahoe 업그레이드 후 문제**: v3.0.0 이상으로 업데이트하세요

## License

MIT
