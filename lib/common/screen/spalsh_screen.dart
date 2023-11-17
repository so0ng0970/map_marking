import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/common/screen/home_screen.dart';

import '../../user/screen/login_sign_screen.dart';
import '../const/color.dart';

class SplashScreen extends StatefulWidget {
  static String get routeName => 'splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(
          seconds: 5,
        ), () {
      checkAuthStatus();
    });
  }

  Future<void> checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Firebase에 로그인된 사용자가 있으면 HomeScreen으로 이동
      context.goNamed(HomeScreen.routeName);
    } else {
      // Firebase에 로그인된 사용자가 없으면 LoginPage로 이동
      context.goNamed(LoginSignScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SPLASH_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo/MAAP.png',
              scale: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 55.0,
              ),
              child: SizedBox(
                height: 90,
                child: AnimatedTextKit(
                  totalRepeatCount: 1,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '내가 남기는 발자취',
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                      ),
                      speed: const Duration(
                        milliseconds: 200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
