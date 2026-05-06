# Mobile Issue Tracker with Offline Persistence

## Overview

This Flutter app allows users to create, view, update, filter, and resolve issues.  
The app loads initial mock API data, stores data locally using SharedPreferences, and remains usable after app restart.

## Features Completed

- Mock login screen with email/password validation
- Issue list screen
- Dashboard summary with Open, In Progress, and Resolved counts
- Create issue form
- Edit issue form
- Issue detail screen
- Mark issue as Resolved or Closed with confirmation
- Search by title
- Filter by status and priority
- Loading, empty, and error states
- Pull-to-refresh from mock API
- Local persistence using SharedPreferences
- Offline-first style local save
- Pending sync indicator using `isSynced`
- Export issues to JSON
- Light and dark mode support
- Clean Provider-based state management
- Basic separation between UI, provider, services, and models

## Tech Stack

- Flutter
- Dart
- Provider
- SharedPreferences
- Mock API service
- share_plus
- path_provider

## Setup

```bash
flutter pub get
flutter run
