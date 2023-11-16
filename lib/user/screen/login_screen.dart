import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/common/screen/home_screen.dart';

import '../../common/const/color.dart';

class LoginScreen extends StatefulWidget {
  static String get routeName => 'login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool sign = false;
  @override
  Widget build(BuildContext context) {
    TextFormField textFormField(String hintText) {
      return TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: WHITE_COLOR,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: WHITE_COLOR),
            borderRadius: BorderRadius.circular(40.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: LOGIN_BG),
            borderRadius: BorderRadius.all(
              Radius.circular(
                50,
              ),
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
            borderRadius: BorderRadius.all(
              Radius.circular(
                50,
              ),
            ),
          ),
          hintText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        ),
      );
    }

    return Scaffold(
      backgroundColor: LOGIN_BG,
      body: SafeArea(
        child: Stack(
          children: [
            IconButton(
              onPressed: () {
                if (!sign) {
                  context.goNamed(HomeScreen.routeName);
                }
                if (sign) {
                  setState(() {
                    sign = !sign;
                    print(sign);
                  });
                }
              },
              icon: Icon(
                sign ? Icons.arrow_back : Icons.close,
                size: 40,
                color: LOGIN_CLOSE_BUTTON,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 480,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: LOGIN_SUB_BG,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                  child: Form(
                    child: Column(
                      children: [
                        Text(
                          sign ? 'SIGN' : 'LOGIN',
                          style: const TextStyle(
                            fontSize: 30,
                            color: SIGN_BUTTON_BORDER,
                          ),
                        ),
                        SizedBox(
                          height: sign ? 50 : 10,
                        ),
                        textFormField('이메일'),
                        const SizedBox(
                          height: 20,
                        ),
                        if (sign)
                          textFormField(
                            '닉네임',
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        textFormField('비밀번호'),
                        const SizedBox(
                          height: 20,
                        ),
                        if (sign)
                          textFormField(
                            '비밀번호 확인',
                          ),
                        SizedBox(
                          height: sign ? 138 : 90,
                        ),
                        if (!sign)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                '회원이 아니신가요?',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: LOGIN_BUTTON_BORDER,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    sign = true;
                                  });

                                  print(sign);
                                },
                                child: const Text(
                                  '회원가입 하기',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: SIGN_BUTTON_BORDER,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LOGIN_BUTTON,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  40,
                                ),
                              ),
                              side: const BorderSide(
                                color: LOGIN_BUTTON_BORDER,
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              sign ? '회원가입 하기' : '로그인 하기',
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              child: Image.asset(
                'assets/images/icon/character1.png',
                scale: 3,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Image.asset(
                'assets/images/icon/cloud.png',
                scale: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
