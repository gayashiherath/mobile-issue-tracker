# Mobile Issue Tracker with Offline Persistence

## Overview

This Flutter app allows users to create, view, update, filter, and resolve issues.  
The app loads initial mock API data, stores data locally using SharedPreferences, and remains usable after app restart.


## Completed Features

- Authentication screen with email/password validation (mock login)
- Issue list screen with:
    * Title, status, priority, and created date
    * Search and filter (status & priority)
- Dashboard summary showing:
    * Open, In Progress, and Resolved counts
- Create issue form with validation
- Edit existing issues
- Issue detail screen with full information
- Mark issue as Resolved or Closed with confirmation dialogs
- Pull-to-refresh from mock API
- Loading, empty, and error states handling
- Local persistence using SharedPreferences (data survives app restart)
- Offline-friendly behavior (local changes stored and marked as unsynced)
- Export issues as JSON file with sharing support
- Dark mode and light mode support
- Clean folder structure with separation of:
    * UI
    * State management (Provider)
    * Services (API & local storage)
- Reusable UI components (buttons, text fields, cards)
- Basic unit tests for form validation
  

 ## Partially Implemented / Skipped Features
 
- Widget/UI tests: Only basic validation tests are included. Full widget testing for screen flows is not implemented.
- Real backend integration: A mock API service is used instead of a real backend.


## Tech Stack

- Flutter
- Dart
- Provider
- SharedPreferences
- Mock API service
- share_plus
- path_provider
  

## Assumptions

- API is mocked using a local service.
- Created and edited issues are stored locally.
- Sync is not connected to a real backend.
- Unsynced local changes are marked with a cloud-off icon.



## Setup

```bash
flutter pub get
flutter run
