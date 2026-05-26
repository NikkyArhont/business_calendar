import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final g_auth.GoogleSignIn _googleSignIn = g_auth.GoogleSignIn();

  // Поток изменений состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Текущий пользователь
  User? get currentUser => _auth.currentUser;

  // Отправка SMS кода
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Автоматический вход (только на Android при определенных условиях)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (kDebugMode) print('Error verifying phone: $e');
    }
  }

  // Вход по коду из SMS
  Future<UserCredential?> signInWithCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) print('Error signing in with code: $e');
      rethrow;
    }
  }

  // Вход через Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      
      if (kIsWeb) {
        // Для Web используем встроенный в Firebase метод
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Для мобильных платформ используем google_sign_in
        final g_auth.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final g_auth.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }
      
      // Сразу создаем/обновляем базовый профиль
      if (userCredential.user != null) {
        await updateUserProfile(
          name: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email,
          photoUrl: userCredential.user!.photoURL,
        );
      }
      
      return userCredential;
    } catch (e) {
      if (kDebugMode) print('Error signing in with Google: $e');
      final errorStr = e.toString();
      // Если пользователь просто закрыл окно входа, возвращаем null без проброса ошибки
      if (errorStr.contains('popup-closed-by-user') || 
          errorStr.contains('sign_in_canceled') ||
          errorStr.contains('cancelled') ||
          errorStr.contains('canceled')) {
        return null;
      }
      rethrow;
    }
  }

  // Проверка, заполнен ли профиль (существует ли документ в Firestore)
  Future<bool> isProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists && doc.data()?['name'] != null;
  }

  // Обновление профиля пользователя в Firestore
  Future<void> updateUserProfile({
    required String name,
    String? email,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': email ?? user.email,
      'photoUrl': photoUrl ?? user.photoURL,
      'phoneNumber': user.phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
      'isFirstTime': false,
    }, SetOptions(merge: true));
  }

  // Выход
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
