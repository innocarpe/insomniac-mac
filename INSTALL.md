# Caffeine 설치 가이드

## 빠른 설치 (현재 디렉토리에서)

```bash
# 1. 앱을 Applications 폴더로 이동
mv Caffeine.app /Applications/

# 2. 앱 실행
open /Applications/Caffeine.app
```

## 처음부터 빌드하기

```bash
# 1. 프로젝트 빌드
swift build -c release

# 2. 앱 번들 생성
./scripts/create-app.sh

# 3. 앱 아이콘 생성
./scripts/generate-icon.swift

# 4. Applications로 이동
mv Caffeine.app /Applications/
```

## 첫 실행 시

1. **보안 경고**: 처음 실행 시 "개발자를 확인할 수 없습니다" 메시지가 나타날 수 있습니다.
   - Caffeine.app을 우클릭
   - "열기" 선택
   - 경고 창에서 "열기" 클릭

2. **권한 요청**: 카페인 모드를 토글할 때 관리자 비밀번호를 요청합니다.
   - 이는 시스템 전원 설정을 변경하기 위함입니다.

## 사용 방법

- **메뉴바 아이콘**
  - ☕ (채워진 컵): 카페인 모드 ON - 맥북이 잠들지 않음
  - ☕ (빈 컵): 카페인 모드 OFF - 정상 작동

- **조작**
  - 좌클릭: 카페인 모드 ON/OFF 토글
  - 우클릭: 메뉴 표시
    - 시작 시 실행 설정
    - 정보
    - 종료

## 제거 방법

```bash
# 앱 제거
rm -rf /Applications/Caffeine.app

# 설정 제거 (선택사항)
defaults delete com.personal.caffeine
```

## 문제 해결

- **아이콘이 보이지 않는 경우**: 시스템 환경설정 > 보안 및 개인정보 확인
- **토글이 작동하지 않는 경우**: 터미널에서 `pmset -g` 명령으로 현재 상태 확인