# MamaApp iOS Installation Guide

## Building on Mac

If you have a Mac:

```bash
cd mobile
flutter build ios --release --no-codesign
```

Then create IPA:
```bash
cd build/ios/iphoneos
mkdir Payload
cp -r Runner.app Payload/
zip -r MamaApp.ipa Payload
```

## Building via GitHub Actions (No Mac Required)

1. Push code to GitHub
2. Go to Actions → "Build iOS IPA" → Run workflow
3. Wait ~15 minutes
4. Download the `MamaApp-iOS` artifact
5. Extract to get `MamaApp.ipa`

## Installing via AltStore

1. **On your iPhone**: Open AltStore
2. Tap **My Apps** → **+** (top left)
3. Select `MamaApp.ipa` from Files
4. Wait for installation (~30 seconds)
5. **Trust the app**: Settings → General → VPN & Device Management → Trust

## Apple Watch Integration

MamaApp automatically reads Apple Watch data through HealthKit:

| Watch Sensor | App Feature |
|--------------|-------------|
| Heart Rate   | Continuous HR monitoring |
| Blood Oxygen | SpO2 readings |
| Sleep        | Fatigue assessment |
| Steps        | Activity tracking |

### How it works:
- Apple Watch syncs data to iPhone's HealthKit
- MamaApp reads from HealthKit (with your permission)
- No separate Watch app needed!

### First Launch:
1. App will ask for HealthKit permissions
2. Grant access to Heart Rate, Blood Oxygen, etc.
3. Watch data appears in Quick Monitor screen

## Troubleshooting

**"Untrusted Developer" error:**
- Settings → General → VPN & Device Management → Trust developer profile

**AltStore signing expires (7 days):**
- Reconnect iPhone to computer with AltServer running
- AltStore auto-refreshes the signature

**HealthKit permissions not appearing:**
- Go to Settings → Health → Data Access → MamaApp
- Toggle on the data types you want

## Refreshing App (Every 7 Days)

With free Apple ID, apps must be refreshed every 7 days:

1. Keep AltServer running on your Windows PC
2. Connect iPhone to same WiFi
3. AltStore refreshes automatically in background

Or manually: AltStore → My Apps → hold MamaApp → Refresh
