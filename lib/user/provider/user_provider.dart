import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/user_model.dart';

final userProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  return ref.watch(authProvider.notifier).getUserFirestore();
});
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  AuthProvider({
    required this.ref,
  }) {
    _firebaseAuth.authStateChanges().listen((user) {
      currentUser = user;
      notifyListeners();
    });
  }
  // 유저 정보 get
  Stream<UserModel?> getUserFirestore() {
    if (currentUser == null) {
      return Stream.value(null);
    } else {
      return _firestore
          .collection('user')
          .doc(currentUser?.uid)
          .snapshots()
          .map((snapshot) {
        final user = UserModel.fromJson(snapshot.data()!);
        return user.isEmpty ? null : user;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }
}
