# Providers
This folder contains state management providers using the Provider package.

## Files
- `student_provider.dart` - Manages student data and business logic
- `theme_provider.dart` - Manages application theme state

## Guidelines
- Each provider should handle one domain
- Use ChangeNotifier for state management
- Call notifyListeners() when state changes
