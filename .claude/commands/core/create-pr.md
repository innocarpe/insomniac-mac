# Pull Request 작성

다음 단계를 순서대로 실행하여 PR을 생성하세요:

## 1단계: 변경사항 분석
1. 현재 Git 상태 확인:
   ```bash
   git status
   git diff origin/main...HEAD --name-only
   git diff origin/main...HEAD --stat
   ```

2. 변경된 파일 분석:
   - 파일 경로와 확장자 확인
   - 변경 내용의 성격 파악 (기능 추가/버그 수정/문서화 등)
   - 영향 범위 평가

## 2단계: 브랜치 푸시 (필수)
```bash
git push origin HEAD --force
```

## 3단계: 저장소 라벨 확인 (필수)
```bash
gh label list
```
**중요**: 실제 존재하는 라벨만 사용해야 함. 존재하지 않는 라벨 사용 시 PR 생성 실패.

## 4단계: PR 제목 생성 (Conventional Commits)
**형식**: `<type>(<scope>): <description>`

### Type 매핑:
- 새 기능: `feat`
- 버그 수정: `fix`
- 문서: `docs`
- 스타일: `style`
- 리팩토링: `refactor`
- 성능: `perf`
- 테스트: `test`
- 기타: `chore`
- 보안: `security`

### Scope 매핑 (파일 경로 기반):
- `Sources/Caffeine/` → `app`, `ui`, `power`, `timer`
- `.claude/` → `claude`
- `.github/workflows/` → `ci`
- `Package.swift` → `spm`
- `README.md`, `docs/` → `docs`
- `scripts/` → `scripts`

### 기능별 세부 Scope:
- 전원 관리 → `power`
- 타이머 기능 → `timer`
- 상태바/메뉴 UI → `ui`
- 권한/보안 → `auth`
- 시작 시 실행 → `startup`
- 아이콘 → `icon`

## 5단계: 라벨 자동 결정

### 기본 라벨 매핑:
- Type 기반: `feat`, `fix`, `docs`, `style`, `refactor`, `performance`, `test`, `chore`, `security`
- 기능 영역: `power-management`, `timer`, `ui`, `auth`, `startup`, `icon`
- 시스템: `macos`, `swift`, `spm`
- 우선순위: `priority/critical`, `priority/high`, `priority/medium`, `priority/low`

### 우선순위 결정:
- `critical|urgent|hotfix` → `priority/critical`
- `important|high` → `priority/high`
- `low|minor` → `priority/low`
- 기본값 → `priority/medium`

### UI 라벨 세부 매핑:
- 메뉴바 UI 작업 → `ui`
- 타이머 UI → `timer`
- 아이콘 관련 → `icon`
- 시스템 통합 → `macos`

## 6단계: PR 본문 작성 및 임시 파일 생성
edit_file 도구를 사용하여 `/tmp/pr_body.md` 파일에 다음 템플릿으로 작성:

```markdown
## 📋 작업 내용

### [주요 변경사항 제목]
- **파일명**: 변경 내용 설명
- **파일명**: 변경 내용 설명

## 🔧 주요 개선사항

### 1. [개선사항 1]
- 구체적인 개선 내용
- 기술적 세부사항

### 2. [개선사항 2]
- 구체적인 개선 내용
- 기술적 세부사항

## 📊 변경 통계
- X개 파일 변경
- X줄 추가
- X줄 삭제

## 🎯 기대 효과
- 구체적인 효과 1
- 구체적인 효과 2

## 🔍 테스트 방법
1. 테스트 단계 1
2. 테스트 단계 2

## 📝 관련 이슈
- 관련 이슈나 배경 설명
```

## 7단계: PR 생성 실행
```bash
# 1. 브랜치 푸시 (필요시)
git push origin HEAD

# 2. PR 생성 (확인된 라벨만 사용)
gh pr create --title "생성된_제목" --body-file /tmp/pr_body.md --base main --label "확인된,라벨들"

# 3. 임시 파일 정리
rm /tmp/pr_body.md

# 4. PR 웹페이지 열기
gh pr view --web
```

## 8단계: 오류 처리
라벨 오류 발생 시:
```bash
# 라벨 없이 PR 생성
gh pr create --title "제목" --body-file /tmp/pr_body.md --base main

# 나중에 라벨 추가
gh pr edit [PR번호] --add-label "존재하는_라벨"
```

## 체크리스트
- [ ] 변경사항 분석 완료
- [ ] 실제 저장소 라벨 확인 완료
- [ ] Conventional Commits 스타일 제목 작성
- [ ] 적절한 라벨 선택 (실제 존재하는 라벨만)
- [ ] PR 본문 임시 파일 생성
- [ ] PR 생성 및 임시 파일 정리
- [ ] PR 확인

## 예시

### 타이머 기능 추가:
- 제목: `feat(timer): 카페인 자동 종료 타이머 추가`
- 라벨: `feat,timer,priority/medium`

### UI 개선:
- 제목: `feat(ui): 실시간 타이머 카운트다운 표시`
- 라벨: `feat,ui,timer,priority/medium`

### 버그 수정:
- 제목: `fix(power): pmset 명령어 실행 권한 오류 수정`
- 라벨: `fix,power-management,auth,priority/high`

**중요사항**:
- 반드시 `gh label list` 결과를 기반으로 라벨 선택
- 존재하지 않는 라벨 사용 금지
- 임시 파일을 통한 본문 작성으로 newline 문제 방지
- Conventional Commits 스타일 준수
