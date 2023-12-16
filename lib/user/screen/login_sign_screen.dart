import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:map_marking/common/screen/home_screen.dart';
import 'package:map_marking/user/component/check_validate.dart';
import 'package:map_marking/user/component/custom_email.dart';
import 'package:map_marking/user/provider/login_sign_provider.dart';

import '../../common/const/color.dart';

class LoginSignScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login_sign';
  const LoginSignScreen({super.key});

  @override
  ConsumerState<LoginSignScreen> createState() => _LoginSignScreenState();
}

class _LoginSignScreenState extends ConsumerState<LoginSignScreen> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode nicknameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();

  bool sign = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? tokenType;
  String? accessToken;
  String? refreshToken;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
    final provider = ref.watch(loginSignProvider.notifier);
    TextFormField textFormField({
      required String hintText,
      TextEditingController? controller,
      FocusNode? focusNode,
      String? Function(String?)? validator,
      void Function(String)? onChanged,
      int? maxLength,
      bool? obscureText,
      required TextInputType keyboardType,
      required Key key,
    }) {
      return TextFormField(
        key: key,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        validator: validator,
        maxLength: maxLength,
        keyboardType: keyboardType,
        obscureText: obscureText ?? false,
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
                    emailFocus.unfocus();
                    passwordFocus.unfocus();
                    nicknameFocus.unfocus();
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
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
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
                              key: sign ? const ValueKey(5) : const ValueKey(1),
                              controller: emailController,
                              focusNode: emailFocus,
                              validator: (val) => CheckValidate()
                                  .validateEmail(emailFocus, val!),
                              keyboardType: TextInputType.emailAddress,
                              hintText: '이메일',
                              onChanged: (_) {
                                _showEmailOverlay();
                                _updateEmailOverlay();
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (sign)
                            textFormField(
                              key: const ValueKey(2),
                              maxLength: 15,
                              focusNode: nicknameFocus,
                              controller: nicknameController,
                              validator: (val) => CheckValidate()
                                  .validateNickName(nicknameFocus, val!),
                              keyboardType: TextInputType.name,
                              hintText: '닉네임',
                            ),
                          textFormField(
                            key: sign ? const ValueKey(6) : const ValueKey(3),
                            focusNode: passwordFocus,
                            controller: passwordController,
                            obscureText: true,
                            validator: (val) => CheckValidate()
                                .validatePassword(passwordFocus, val!),
                            keyboardType: TextInputType.name,
                            hintText: '비밀번호',
                          ),
                          SizedBox(
                            height: sign ? 30 : 20,
                          ),
                          if (sign)
                            textFormField(
                              key: const ValueKey(4),
                              obscureText: true,
                              keyboardType: TextInputType.name,
                              validator: (val) => CheckValidate()
                                  .validatePasswordConfirmation(
                                      confirmPasswordFocus,
                                      val!,
                                      passwordController.text),
                              hintText: '비밀번호 (확인)',
                            ),
                          SizedBox(
                            height: sign ? 48 : 50,
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
                                      emailFocus.unfocus();
                                      passwordFocus.unfocus();
                                      nicknameFocus.unfocus();
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
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  if (sign) {
                                    provider.registerUser(
                                      context,
                                      mounted,
                                      nicknameController,
                                      emailController,
                                      passwordController,
                                    );
                                  } else {
                                    ref
                                        .watch(loginSignProvider.notifier)
                                        .signInUser(context, emailController,
                                            passwordController);
                                  }
                                }
                              },
                              child: Text(
                                sign ? '회원가입 하기' : '로그인 하기',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          if (!sign)
                            const SizedBox(
                              height: 15,
                            ),
                          if (!sign)
                            const Divider(
                              thickness: 1,
                              height: 1,
                              color: LOGIN_DIVICE,
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (!sign)
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final NaverLoginResult user =
                                      await FlutterNaverLogin.logIn();
                                  NaverAccessToken res = await FlutterNaverLogin
                                      .currentAccessToken;

                                  setState(() {
                                    accessToken = res.accessToken;
                                    tokenType = res.tokenType;
                                    refreshToken = res.refreshToken;
                                  });

                                  String id = user.account.email;
                                  String name = user.account.name;
                                  String profileImage =
                                      user.account.profileImage;
                                  String idx = user.account.id.toString();

                                  print('$id,$name, $idx');

                                  // Firebase 인증 정보로 변환
                                  final AuthCredential credential =
                                      OAuthProvider('naver').credential(
                                    accessToken: accessToken,
                                  );

                                  // Firebase에 로그인
                                  final UserCredential authResult =
                                      await FirebaseAuth.instance
                                          .signInWithCredential(credential);
                                  final User firebaseUser = authResult.user!;

                                  if (firebaseUser != null) {
                                    print(
                                        'Firebase에 로그인 성공: ${firebaseUser.uid}');
                                  } else {
                                    print('Firebase에 로그인 실패');
                                  }
                                } catch (error) {
                                  print('naver login error $error');
                                }
                              },
                              child: SizedBox(
                                height: 50,
                                child: Image.asset(
                                  'assets/images/logo/naver_login.png',
                                ),
                              ),
                            ),
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

  void _updateEmailOverlay() {
    _overlayEntry?.markNeedsBuild(); // OverlayEntry를 업데이트합니다.
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
