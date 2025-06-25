#!/bin/bash

# GitHub 라벨 생성 스크립트 - Insomniac macOS 앱
# 사용법: ./scripts/create-pr-labels.sh

echo "🏷️  Insomniac 프로젝트 GitHub 라벨 생성 중..."

# 작업 유형 라벨 (Conventional Commits 기반)
echo "📝 작업 유형 라벨 생성..."
gh label create "feat" --description "새로운 기능 추가" --color "0066cc" --force
gh label create "fix" --description "버그 수정" --color "d73a4a" --force
gh label create "docs" --description "문서 변경" --color "0075ca" --force
gh label create "style" --description "코드 포맷팅, 스타일" --color "f9d0c4" --force
gh label create "refactor" --description "코드 리팩토링" --color "fbca04" --force
gh label create "perf" --description "성능 개선" --color "0e8a16" --force
gh label create "test" --description "테스트 추가/수정" --color "1d76db" --force
gh label create "chore" --description "빌드, 설정, 도구" --color "fef2c0" --force
gh label create "security" --description "보안 관련 수정" --color "b60205" --force
gh label create "ai" --description "Claude Code, AI 도구 개선" --color "9c27b0" --force
gh label create "prd" --description "기획 문서, 진행상황" --color "795548" --force
gh label create "wip" --description "작업 중 (squash 예정)" --color "ffeb3b" --force

# 우선순위 라벨
echo "⚡ 우선순위 라벨 생성..."
gh label create "priority/critical" --description "즉시 처리 필요" --color "b60205" --force
gh label create "priority/high" --description "높은 우선순위" --color "d93f0b" --force
gh label create "priority/medium" --description "보통 우선순위" --color "fbca04" --force
gh label create "priority/low" --description "낮은 우선순위" --color "0e8a16" --force

# 주요 영역 스코프 라벨
echo "🏗️  주요 영역 라벨 생성..."
gh label create "app" --description "앱 전체 설정, 진입점" --color "2196f3" --force
gh label create "ui" --description "상태바 UI, 메뉴 관련" --color "4caf50" --force
gh label create "power" --description "전원 관리, 카페인 모드" --color "ff9800" --force
gh label create "core" --description "핵심 비즈니스 로직" --color "9c27b0" --force

# 특화 영역 스코프 라벨
echo "⚙️  특화 영역 라벨 생성..."
gh label create "timer" --description "타이머 기능 관련" --color "00bcd4" --force
gh label create "icon" --description "아이콘 생성 및 관리" --color "e91e63" --force
gh label create "startup" --description "시작 시 실행 기능" --color "673ab7" --force
gh label create "auth" --description "권한, sudoers 설정" --color "f44336" --force
gh label create "notif" --description "알림 관련 기능" --color "ff5722" --force

# 인프라/배포 스코프 라벨
echo "🚀 인프라/배포 라벨 생성..."
gh label create "build" --description "빌드, 앱 번들 생성" --color "795548" --force
gh label create "ci" --description "GitHub Actions, CI/CD" --color "607d8b" --force
gh label create "release" --description "릴리스, 배포 관련" --color "3f51b5" --force

# 개발 도구/설정 스코프 라벨
echo "🛠️  개발 도구 라벨 생성..."
gh label create "spm" --description "Swift Package Manager" --color "ff6f00" --force
gh label create "config" --description "설정 파일 (Info.plist 등)" --color "8bc34a" --force
gh label create "deps" --description "의존성 관리" --color "cddc39" --force
gh label create "scripts" --description "스크립트, 자동화 도구" --color "ffc107" --force

# 문서/관리 스코프 라벨
echo "📚 문서/관리 라벨 생성..."
gh label create "claude" --description "Claude 관련 설정, 문서" --color "00e676" --force

# 리뷰/임시 작업 스코프 라벨
echo "🔍 리뷰/임시 작업 라벨 생성..."
gh label create "review" --description "코드 리뷰 피드백 반영" --color "e1bee7" --force
gh label create "hotfix" --description "긴급 수정사항" --color "d32f2f" --force

# 플랫폼/기술 라벨
echo "💻 플랫폼/기술 라벨 생성..."
gh label create "macos" --description "macOS 관련" --color "1976d2" --force
gh label create "swift" --description "Swift 언어 관련" --color "fa7343" --force

# 상태 라벨
echo "📊 상태 라벨 생성..."
gh label create "breaking-change" --description "호환성 깨짐" --color "d73a4a" --force
gh label create "needs-testing" --description "테스트 필요" --color "ffeb3b" --force
gh label create "ready-for-review" --description "리뷰 준비 완료" --color "0e8a16" --force

echo ""
echo "✅ Insomniac 프로젝트 라벨 생성 완료!"
echo ""
echo "📋 생성된 라벨 목록:"
gh label list --limit 100
echo ""
echo "🎯 주요 라벨 조합 예시:"
echo "   feat + timer + priority/medium"
echo "   fix + power + priority/high"
echo "   refactor + ui + macos"
echo "   chore + build + scripts"
echo ""
echo "💡 커밋 메시지와 매칭되는 라벨을 사용하여 PR을 생성하세요!"