# Caffeine 비밀번호 없이 사용하기

## 개요
Caffeine은 기본적으로 카페인 모드를 켜고 끌 때마다 관리자 비밀번호를 요구합니다. 이는 시스템의 전원 관리 설정을 변경하기 때문입니다.

하지만 매번 비밀번호를 입력하는 것이 불편하다면, 한 번의 설정으로 비밀번호 없이 사용할 수 있습니다.

## 설정 방법

### 방법 1: 앱 내에서 설정 (권장)
1. Caffeine 앱을 실행합니다
2. 메뉴바의 커피잔 아이콘을 우클릭합니다
3. "비밀번호 없이 사용 설정..." 메뉴를 클릭합니다
4. 안내 창이 나타나면 "설정" 버튼을 클릭합니다
5. 관리자 비밀번호를 입력합니다 (이번 한 번만)
6. "설정 완료" 메시지가 나타나면 완료!

### 방법 2: 터미널에서 설정
```bash
# 프로젝트 디렉토리에서
./scripts/setup-passwordless.sh

# 또는 직접 명령어 실행
echo '%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -b disablesleep 0, /usr/bin/pmset -b disablesleep 1' | sudo tee /etc/sudoers.d/caffeine
sudo chmod 0440 /etc/sudoers.d/caffeine
```

## 작동 원리
이 설정은 macOS의 sudoers 시스템을 사용하여 특정 명령어(`pmset -b disablesleep`)만 비밀번호 없이 실행할 수 있도록 허용합니다.

- 보안: 오직 Caffeine이 사용하는 특정 pmset 명령어만 허용됩니다
- 범위: 다른 시스템 설정이나 명령어에는 영향을 주지 않습니다

## 설정 제거
비밀번호 없이 사용하는 설정을 제거하려면:

```bash
sudo rm /etc/sudoers.d/caffeine
```

이후에는 다시 카페인 모드를 토글할 때마다 비밀번호를 입력해야 합니다.

## 문제 해결

### 설정 후에도 비밀번호를 묻는 경우
1. 터미널에서 다음 명령어로 설정 확인:
   ```bash
   sudo cat /etc/sudoers.d/caffeine
   ```

2. 파일이 없거나 내용이 잘못된 경우 다시 설정

### 보안 관련 참고사항
- 이 설정은 admin 그룹의 사용자만 pmset의 특정 명령어를 비밀번호 없이 실행할 수 있게 합니다
- 시스템의 다른 보안 설정에는 영향을 주지 않습니다
- 신뢰할 수 없는 환경에서는 이 설정을 사용하지 않는 것이 좋습니다