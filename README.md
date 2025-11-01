# Notes App

![Flutter](https://img.shields.io/badge/Flutter-3.13-blue?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-1.0-ff5a5f?logo=supabase)
![License](https://img.shields.io/badge/License-MIT-green)

A Flutter-based Notes application with user authentication and profile management, powered by Supabase.

---

## Features

- **User Authentication**  
  - Sign up with email and password  
  - Log in and log out  

- **Profile Management**  
  - Update name, bio, and avatar  
  - Upload avatar images to Supabase storage  
  - Delete account permanently  

- **Responsive UI**  
  - Works well on mobile and tablet devices  

- **Loading States**  
  - Displays progress indicators when performing network operations  

---

## Screenshots

*(Add your screenshots here)*

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0
- Dart >= 3.0
- Supabase account
- Android/iOS simulator or physical device

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/notes_app.git
cd notes_app


Install dependencies:
flutter pub get


Configure Supabase:
Replace the Supabase URL and anon key in main.dart:


await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);

Run the app:
flutter run



Project Structure:
lib/
├── auth/
│   ├── auth_gate.dart
│   ├── auth_service.dart
│   ├── global_loader.dart
│   └── loading_provider.dart
├── pages/
│   ├── login_page.dart
│   ├── register_page.dart
│   └── profile_page.dart
├── main.dart
└── app_colors.dart




---
