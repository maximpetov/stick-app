# Stick

A macOS application to track earnings from Toggl Track.

## Features

- Track monthly earnings based on logged hours
- Integration with Toggl Track API v9
- Native macOS UI
- USD currency support

## Setup

1. Open the project in Xcode
2. Build and run (Cmd+R)
3. Enter your Toggl API token and hourly rate
4. The app will calculate your earnings based on tracked time entries

## Files

- `StickApp.swift` - Main app entry point
- `MenuBarContentView.swift` - Root view controller
- `MainView.swift` - Main earnings display view
- `SettingsView.swift` - Settings/configuration view
- `TogglService.swift` - Toggl API integration and utilities

## API Token

Get your Toggl API token from: toggl.com → Profile Settings → API Token
