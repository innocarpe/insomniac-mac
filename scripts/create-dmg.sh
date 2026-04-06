#!/bin/bash

# DMG 생성 스크립트
# Caffeine 앱을 배포 가능한 DMG 파일로 패키징

set -e

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Insomniac DMG 생성 시작...${NC}"

# 변수 설정
APP_NAME="Insomniac"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION}"
SOURCE_DIR="dmg-source"
APP_PATH="${APP_NAME}.app"
AUTHOR="Wooseong Kim"
EMAIL="innocarpe@gmail.com"

# 기존 DMG 파일 제거
if [ -f "$DMG_NAME" ]; then
    echo -e "${YELLOW}기존 DMG 파일 제거중...${NC}"
    rm -f "$DMG_NAME"
fi

# 임시 디렉토리 생성
echo -e "${GREEN}임시 디렉토리 생성중...${NC}"
rm -rf "$SOURCE_DIR"
mkdir -p "$SOURCE_DIR"

# 앱이 없으면 빌드
if [ ! -d "$APP_PATH" ]; then
    echo -e "${YELLOW}앱이 없습니다. 빌드를 시작합니다...${NC}"
    ./scripts/create-app.sh
fi

# 앱 복사
echo -e "${GREEN}앱 복사중...${NC}"
cp -R "$APP_PATH" "$SOURCE_DIR/"

# Applications 심볼릭 링크 생성
ln -s /Applications "$SOURCE_DIR/Applications"

# README 파일 생성
cat > "$SOURCE_DIR/README.txt" << EOF
Insomniac 설치 방법
==================

1. Insomniac.app을 Applications 폴더로 드래그하세요.
2. 처음 실행 시 우클릭 → "열기"를 선택하세요.
3. 메뉴바에 찻잔 아이콘이 나타나면 설치 완료!

비밀번호 입력 없이 바로 사용할 수 있습니다.

주의사항
--------
- macOS 12.0 이상이 필요합니다.
- 인터넷에서 다운로드한 앱이므로 첫 실행 시 우클릭 → 열기가 필요합니다.
- 시작 시 자동 실행을 원하시면 메뉴에서 설정하세요.

제작자 정보
-----------
제작자: $AUTHOR
이메일: $EMAIL
버전: $VERSION

문의사항이 있으시면 위 이메일로 연락주세요.
EOF

# DMG 생성
echo -e "${GREEN}DMG 생성중...${NC}"
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$SOURCE_DIR" \
    -ov -format UDZO \
    "$DMG_NAME"

# 임시 디렉토리 정리
echo -e "${GREEN}정리중...${NC}"
rm -rf "$SOURCE_DIR"

# 완료
echo -e "${GREEN}✓ DMG 생성 완료: $DMG_NAME${NC}"
echo -e "${YELLOW}크기: $(du -h "$DMG_NAME" | cut -f1)${NC}"

# 배포 안내
echo -e "\n${YELLOW}=== 배포 안내 ===${NC}"
echo -e "1. 이 DMG 파일을 그대로 공유할 수 있습니다."
echo -e "2. 사용자들은 첫 실행 시 '우클릭 → 열기'를 해야 합니다."
echo -e "3. 개발자 계정 없이 배포 시 매번 이 과정이 필요합니다."
echo -e ""
echo -e "${YELLOW}팁:${NC} 더 편한 배포를 원하시면:"
echo -e "- Apple 개발자 계정($99/년)으로 코드 서명 및 공증"
echo -e "- 또는 Homebrew Cask를 통한 배포를 고려해보세요."