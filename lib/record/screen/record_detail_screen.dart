// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:map_marking/common/const/color.dart';

class RecordDetailScreen extends StatefulWidget {
  bool markerTap;
  final Function(bool) onMarkerTapChanged;
  RecordDetailScreen({
    Key? key,
    required this.markerTap,
    required this.onMarkerTapChanged,
  }) : super(key: key);

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.drag_handle,
          color: LOCATION,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MARKER_BUTTON,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                setState(() {
                  widget.markerTap = true;
                  widget.onMarkerTapChanged(widget.markerTap);
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  '작성하기',
                  style: TextStyle(color: RECORD_TEXT, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          color: Colors.amber,
          height: 100,
          child: Row(
            children: [
              Image.asset(
                'assets/images/icon/character1.png',
                scale: 4,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '오늘은 여기',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: 290,
                    child: Text(
                      '나는 언덕 잔디가 이 지나가는 헤는 것은 하나에 있습니다. 아무 가을 책상을 아이들의 위에도 하나에 이웃 내린 위에 봅니다.배고프다 헤헤헤헤ㅇㄹㅇㄹㅇㄹㅇㄹ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.fade,
                      maxLines: 3,
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
