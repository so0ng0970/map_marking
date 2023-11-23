import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/common/screen/home_screen.dart';

final loginSignProvider =
    StateNotifierProvider<LoginSignModel, LoginState>((ref) {
  final authentication = FirebaseAuth.instance;

  return LoginSignModel(authentication);
});

class LoginState {
  final bool isLogined;

  LoginState({
    required this.isLogined,
  });
}

class LoginSignModel extends StateNotifier<LoginState> {
  final FirebaseAuth _authentication;

  LoginSignModel(
    this._authentication,
  ) : super(LoginState(isLogined: false));

  Future<void> signInUser(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await _authentication.signInWithCredential(credential);

        context.goNamed(
          HomeScreen.routeName,
        );
      } on FirebaseAuthException {
        // 오류 처리
      }
    } else {
      print('오류가 발생했습니다 ');
    }
  }

  Future<void> registerUser(
    BuildContext context,
    bool mounted,
    TextEditingController nicknameFocusController,
    TextEditingController emailFocusController,
    TextEditingController passwordFocusController,
  ) async {
    final authentication = FirebaseAuth.instance;
    final firebaseStorage = FirebaseStorage.instance;
    final ref = firebaseStorage.ref().child('user/profile.png');

    String photoUrl = await ref.getDownloadURL();

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    formKey.currentState?.validate();
    try {
      final newUser = await authentication.createUserWithEmailAndPassword(
        email: emailFocusController.text,
        password: passwordFocusController.text,
      );
      String displayName = nicknameFocusController.text;

      // await newUser.user?.updateProfile(displayName: displayName);

      final userData = {
        'photoUrl': photoUrl,
        'userName': displayName,
        'email': emailFocusController.text,
        'uid': newUser.user!.uid
      };

      await FirebaseFirestore.instance
          .collection('user')
          .doc(newUser.user!.uid)
          .set(userData);

      context.goNamed(HomeScreen.routeName);
    } catch (e) {
      handleRegistrationError(context, mounted, e);
    }
  }

  void handleRegistrationError(BuildContext context, bool mounted, dynamic e) {
    print(e);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일과 비밀번호를 확인해주세요'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
