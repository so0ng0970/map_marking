// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/const/color.dart';

class ButtonLayout extends StatelessWidget {
  VoidCallback onPressed;
  String text;
  ButtonLayout({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Dialog(
        child: Container(
          decoration: BoxDecoration(
            color: BUTTON_BG,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: BUTTON_BORDER,
            ),
          ),
          height: 200,
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                text,
                style: const TextStyle(
                  color: BUTTON_TEXT,
                  fontSize: 17,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text(
                      '아니요',
                      style: TextStyle(
                        color: PHOTO_BUTTON,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onPressed,
                    child: const Text(
                      '네',
                      style: TextStyle(
                        color: DROP_TEXT_1,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      Positioned(
        top: 170,
        right: 150,
        child: Image.asset(
          'assets/images/icon/character4.png',
          scale: 5,
        ),
      ),
    ]);
  }
}
