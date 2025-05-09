# 📚 Micro Learning Flashcards App

Welcome to the **Micro Learning Flashcards App** – an intuitive Flutter application that helps users learn using customizable flashcards. Integrated with Firebase for authentication and cloud storage, and structured using the BLoC pattern for scalable state management.

![Flutter](https://img.shields.io/badge/Flutter-3.10-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![State Management](https://img.shields.io/badge/BLoC-Clean%20Architecture-purple?logo=dart)

---

## 🚀 Features

- 🔐 **Firebase Authentication**
  - Login & Signup with Email
  - Persistent Auth State
- 🗃️ **Flashcard Decks**
  - Create, Read, Update, Delete (CRUD)
  - Public & Private Decks
- 🌐 **Firestore Integration**
  - Real-time deck syncing
- 🧠 **State Management**
  - Clean architecture using **BLoC** pattern
- 🌓 **Light & Dark Theme Support**
- 👥 Role-based UI with user dashboard
- ✅ Unit tested logic using `firebase_auth_mocks`

---

## 📁 Project Structure

```bash
micro_learning_flashcards/
│
├── lib/
│   ├── blocs/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── deck/
│   │       ├── deck_bloc.dart
│   │       ├── deck_event.dart
│   │       └── deck_state.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── firebase_service.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   └── flashcard_screen.dart
│   │
│   ├── widgets/
│   │   └── card_tile.dart
│   │
│   ├── app_theme.dart
│   └── main.dart
│
├── test/
│   └── blocs/
│       └── auth_bloc_test.dart
│
├── pubspec.yaml
└── README.md

```

# 🛠️ Getting Started


Firebase project with Firestore & Authentication enabled

# Installation
Clone the repo


# How to run
git clone https://github.com/yourusername/micro_learning_flashcards.git
cd micro_learning_flashcards
Install dependencies
flutter pub get
flutter run


# 🔐 Firebase Setup
Ensure your Firebase project has:

- ✅ Authentication → Email/Password enabled

- ✅ Firestore Database in test mode

- ✅ Correct project credentials in FirebaseOptions(...)

#🧪 Testing
flutter test
Unit tests are available for BLoC logic and service classes.





