import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'phoneNumber': user.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'isFirstTime': false,
    }, SetOptions(merge: true));
  }

  // Выход
  Future<void> logout() async {
    await _auth.signOut();
  }
}
