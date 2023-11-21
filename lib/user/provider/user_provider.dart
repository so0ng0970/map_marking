import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthProvider extends ChangeNotifier {
  final Ref ref;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthProvider({
    required this.ref,
  });

 

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }
}
