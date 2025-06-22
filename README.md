# Caffeine

A simple macOS menu bar app to prevent your Mac from going to sleep.

## Features

- One-click toggle to enable/disable sleep prevention
- Visual indicator in menu bar (empty cup = off, filled cup = on)
- Works even when MacBook lid is closed
- Dark mode support
- Minimal resource usage
- Launch at login option
- **NEW: Auto-off timer** - Schedule caffeine to turn off after 30 minutes to 6 hours

## Requirements

- macOS 12.0 (Monterey) or later
- Swift 5.9 or later (for building)

## Quick Install

### Option 1: Build from source
```bash
# Clone the repository
git clone <repository-url>
cd Caffeine

# Build the app
swift build -c release

# Create the app bundle
./scripts/create-app.sh

# Move to Applications
mv Caffeine.app /Applications/
```

### Option 2: Download pre-built
(Coming soon)

## First Launch

1. Right-click on `Caffeine.app` in Applications folder
2. Select "Open" from the context menu
3. Click "Open" in the security dialog
4. **초기 설정**: 첫 실행 시 권한 설정 창이 나타납니다
   - "설정하기" 클릭
   - 관리자 비밀번호 입력 (한 번만)
   - 이후부터는 비밀번호 없이 사용 가능
5. The coffee cup icon will appear in your menu bar

## Usage

- **Left-click**: Toggle caffeine mode on/off
- **Right-click**: Show menu with options
  - Toggle caffeine mode
  - **카페인 타이머**
    - 30분, 1시간, 2시간... 최대 6시간까지 설정 가능
    - OFF 상태에서 설정 시: 자동으로 카페인 모드 ON + 설정 시간 후 OFF
    - ON 상태에서 설정 시: 설정 시간 후 카페인 모드 OFF
    - 타이머 실행 중에는 남은 시간이 메뉴 상단에 실시간 표시
  - Launch at login
  - About
  - Quit

When caffeine is enabled, your Mac won't go to sleep even when you close the lid.

## How it Works

The app uses the `pmset` command to control sleep behavior:
- ON: `pmset -b disablesleep 1` - Prevents sleep on battery
- OFF: `pmset -b disablesleep 0` - Allows normal sleep

첫 실행 시 한 번만 관리자 권한을 설정하면, 이후에는 비밀번호 없이 작동합니다.

## Development

See [CLAUDE.md](CLAUDE.md) for development guidelines and [docs/PRD.md](docs/PRD.md) for detailed product requirements.

### Building
```bash
swift build
swift test
swift run
```

### Creating App Bundle
```bash
./scripts/create-app.sh
```

## Troubleshooting

- **App won't open**: Right-click and select "Open" instead of double-clicking
- **Icon not showing**: Check System Preferences > Security & Privacy
- **Caffeine not working**: Make sure to grant administrator permissions when prompted

## License

Personal use only.