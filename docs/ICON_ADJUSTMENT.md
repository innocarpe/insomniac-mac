# 상태바 아이콘 위치 조정 가이드

Caffeine의 상태바 아이콘이 다른 아이콘들과 정렬이 맞지 않는 경우, 다음과 같은 방법으로 조정할 수 있습니다.

## 현재 적용된 조정사항

1. **커스텀 아이콘 사용**: SF Symbols 대신 직접 그린 아이콘 사용
2. **수직 위치 조정**: -1 픽셀 아래로 이동
3. **아이콘 크기**: 18x18 픽셀 (표준 메뉴바 크기)

## 추가 조정이 필요한 경우

`StatusBarIcon.swift` 파일에서 다음 값들을 조정할 수 있습니다:

```swift
// 수직 위치 조정 (음수 = 아래로, 양수 = 위로)
context?.translateBy(x: 0, y: -1 * scale)

// 아이콘 크기 조정
static func createCoffeeIcon(filled: Bool, size: NSSize = NSSize(width: 18, height: 18))
```

## 미세 조정 방법

1. `StatusBarIcon.swift`의 `translateBy` 값 조정:
   - `y: -2 * scale` - 더 아래로
   - `y: 0` - 중앙 정렬
   - `y: 1 * scale` - 위로

2. 아이콘 전체 크기 조정:
   - `NSSize(width: 16, height: 16)` - 더 작게
   - `NSSize(width: 20, height: 20)` - 더 크게

3. 컵 자체의 위치:
   - `cupY` 값을 조정하여 컵의 수직 위치 변경

## SF Symbols 사용으로 되돌리기

커스텀 아이콘 대신 원래 SF Symbols를 사용하려면:

1. `StatusBarController.swift`에서 `updateIcon()` 메서드 수정
2. `StatusBarIcon.createCoffeeIcon` 호출 부분을 제거
3. SF Symbols 크기와 위치만 조정

## 테스트 방법

1. 코드 수정 후 재빌드: `swift build -c release`
2. 앱 번들 생성: `./scripts/create-app.sh`
3. 실행 중인 앱 종료 후 새로 실행
4. 다른 메뉴바 아이콘과 정렬 확인