import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/common/screen/home_screen.dart';
import 'package:map_marking/user/component/custom_email.dart';

import '../../common/const/color.dart';

class LoginSignScreen extends StatefulWidget {
  static String get routeName => 'login_sign';
  const LoginSignScreen({super.key});

  @override
  State<LoginSignScreen> createState() => _LoginSignScreenState();
}

class _LoginSignScreenState extends State<LoginSignScreen> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode nicknameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool sign = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nicknameController.dispose();
    _removeEmailOverlay();
    _overlayEntry?.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    emailFocus.addListener(() {
      if (!emailFocus.hasFocus) {
        _removeEmailOverlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextFormField textFormField({
      required String hintText,
      required TextEditingController controller,
      FocusNode? focusNode,
      void Function(String)? onChanged,
    }) {
      return TextFormField(
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: WHITE_COLOR,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: WHITE_COLOR),
            borderRadius: BorderRadius.circular(40.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: sign ? SIGN_BORDER : LOGIN_BG),
            borderRadius: const BorderRadius.all(
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
      backgroundColor: sign ? SIGN_BG : LOGIN_BG,
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
                    emailController.clear();
                    passwordController.clear();
                    nicknameController.clear();
                    confirmPasswordController.clear();
                    _removeEmailOverlay();
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
              child: SingleChildScrollView(
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
                            style: TextStyle(
                              fontSize: 30,
                              color: sign ? SIGN_TEXT : SIGN_BUTTON,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CompositedTransformTarget(
                            link: _layerLink,
                            child: textFormField(
                              controller: emailController,
                              focusNode: emailFocus,
                              hintText: '이메일',
                              onChanged: (_) {
                                _showEmailOverlay();
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (sign)
                            textFormField(
                              focusNode: nicknameFocus,
                              controller: nicknameController,
                              hintText: '닉네임',
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          textFormField(
                            focusNode: passwordFocus,
                            controller: passwordController,
                            hintText: '비밀번호',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (sign)
                            textFormField(
                              controller: confirmPasswordController,
                              hintText: '비밀번호 (확인)',
                            ),
                          SizedBox(
                            height: sign ? 48 : 100,
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
                                      emailController.clear();
                                      passwordController.clear();
                                      nicknameController.clear();
                                      confirmPasswordController.clear();
                                      _removeEmailOverlay();
                                    });

                                    print(sign);
                                  },
                                  child: const Text(
                                    '회원가입 하기',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: SIGN_BUTTON,
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
                                backgroundColor:
                                    sign ? SIGN_TEXT : LOGIN_BUTTON,
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
            ),
            MediaQuery.of(context).viewInsets.bottom == 0
                ? Positioned(
                    top: 120,
                    child: Image.asset(
                      sign
                          ? 'assets/images/icon/character2.png'
                          : 'assets/images/icon/character1.png',
                      scale: 3,
                    ),
                  )
                : Container(),
            MediaQuery.of(context).viewInsets.bottom == 0
                ? Positioned(
                    top: -10,
                    right: 10,
                    child: Image.asset(
                      sign
                          ? 'assets/images/icon/star.png'
                          : 'assets/images/icon/cloud.png',
                      scale: sign ? 3 : 2.5,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _showEmailOverlay() {
    if (emailFocus.hasFocus) {
      if (emailController.text.isNotEmpty) {
        final email = emailController.text;

        if (!email.contains('@')) {
          if (_overlayEntry == null) {
            _overlayEntry = _emailListOverlayEntry();
            Overlay.of(context).insert(_overlayEntry!);
          }
        } else {
          _removeEmailOverlay();
        }
      } else {
        _removeEmailOverlay();
      }
    }
  }

  void _removeEmailOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 이메일 자동 입력창
  OverlayEntry _emailListOverlayEntry() {
    return customDropdown.emailRecommendation(
      width: MediaQuery.of(context).size.width - 20,
      layerLink: _layerLink,
      controller: emailController,
      boderColor: SIGN_BG,
      onPressed: () {
        setState(() {
          emailFocus.unfocus();
          _removeEmailOverlay();
        });
      },
    );
  }
}
