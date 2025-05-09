import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:micro_learning_flashcards/services/auth_service.dart';
import 'package:micro_learning_flashcards/services/firebase_service.dart';
//import 'test_setup.mocks.dart'; // This gives you MockAuthService automatically

// Generate mocks
@GenerateMocks(
    [FirebaseAuth, UserCredential, User, FirebaseService, AuthService])
void main() {
  // This file is used to generate mock classes
}
