import '../../domain/entities/app_user.dart';
import '../../data/datasources/local_database.dart';

class AuthService {
  static AppUser? _currentUser;

  static AppUser? get currentUser => _currentUser;

  static AppUser? login(String email, String password) {
    final user = LocalDatabase.login(email, password);
    if (user != null) _currentUser = user;
    return user;
  }

  static Future<void> logout() async {
    _currentUser = null;
  }

  static bool get isLoggedIn => _currentUser != null;
}
