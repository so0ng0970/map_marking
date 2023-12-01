// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../common/const/color.dart';

class RecordScreen extends StatefulWidget {
  bool markerTap;
  final Function(bool) onMarkerTapChanged;
  RecordScreen({
    Key? key,
    required this.markerTap,
    required this.onMarkerTapChanged,
  }) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.drag_handle,
          color: LOCATION,
        ),
        Row(
          children: [
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MARKER_BUTTON,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                setState(() {
                  widget.markerTap = !widget.markerTap;
                });
                widget.onMarkerTapChanged(widget.markerTap);
              },
              child: Text(
                widget.markerTap ? '마커 하기' : '마커 추가하기',
                style: const TextStyle(
                  color: RECORD_TEXT,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
