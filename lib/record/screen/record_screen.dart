// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:map_marking/record/component/down_drop_layout.dart';
import 'package:map_marking/record/component/text_field_layout.dart';

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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedPicGroup;

  final List<String> picGroup = <String>[
    '음식',
    '카페',
    '옷가게',
    '공연',
    '놀거리',
    '미용실',
    '기타'
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const Icon(
            Icons.drag_handle,
            color: LOCATION,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 40,
                width: 120,
                child: dropdownButtonFormField(
                  picGroup: picGroup,
                  selectedPicGroup: selectedPicGroup,
                  onChanged: (selectedItem) => setState(
                    () {
                      selectedPicGroup = selectedItem!;
                    },
                  ),
                ),
              ),
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
          ),
          const SizedBox(
            height: 20,
          ),
          textFormField(
            key: const ValueKey(1),
            borderRadiusSize: 30,
            hintText: '제목',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(
            height: 20,
          ),
          textFormField(
            key: const ValueKey(2),
            borderRadiusSize: 10,
            maxLines: 8,
            keyboardType: TextInputType.emailAddress,
            hintText: '내용을 입력하세요',
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 2,
                color: RECORD_OUTLINE,
              ),
            ),
            height: 150,
            width: 150,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.photo_library_outlined,
                color: PHOTO_BUTTON,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
