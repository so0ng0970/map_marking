// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:uuid/uuid.dart';

import 'package:map_marking/record/layout/down_drop_layout.dart';
import 'package:map_marking/record/layout/text_field_layout.dart';
import 'package:map_marking/record/model/record_model.dart';
import 'package:map_marking/user/component/check_validate.dart';

import '../../common/const/color.dart';
import '../layout/image_layout.dart';
import '../provider/record_detail_provider.dart';

class RecordScreen extends ConsumerStatefulWidget {
  bool markerTap;
  bool recordTap;
  NMarker tapMarker;
  double markerLatitude;
  double markerLongitude;
  Color markerColor;
  final Function(NMarker) onTapMarkerChanged;
  final Function(bool) onMarkerTapChanged;
  final Function(bool) onRecordTapChanged;

  NaverMapController? mapController;
  String testMarker;
  RecordScreen({
    Key? key,
    required this.markerTap,
    required this.recordTap,
    required this.tapMarker,
    required this.markerLatitude,
    required this.markerLongitude,
    required this.markerColor,
    required this.onTapMarkerChanged,
    required this.onMarkerTapChanged,
    required this.onRecordTapChanged,
    required this.mapController,
    required this.testMarker,
  }) : super(key: key);

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<XFile> selectedImages = [];
  final FocusNode titleFocus = FocusNode();
  final FocusNode contentFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final nicknameController = TextEditingController();
  String? selectedPicGroup;
  Uuid uuid = const Uuid();

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
    final postProvider = ref.watch(recordDetailProvider.notifier);
    return Form(
      key: formKey,
      child: Column(
        children: [
          const Icon(
            Icons.drag_handle,
            color: LOCATION,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      removeController();
                      widget.mapController!.deleteOverlay(
                        NOverlayInfo(
                          type: NOverlayType.marker,
                          id: widget.testMarker,
                        ),
                      );
                      widget.onMarkerTapChanged(widget.markerTap);
                      widget.onRecordTapChanged(widget.recordTap);
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: LOCATION,
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.recordTap)
                SizedBox(
                  height: 55,
                  width: 120,
                  child: dropdownButtonFormField(
                    picGroup: picGroup,
                    selectedPicGroup: selectedPicGroup,
                    onChanged: (selectedItem) => setState(
                      () {
                        selectedPicGroup = selectedItem!;
                        int selectedColorIndex =
                            picGroup.indexOf(selectedItem.toString());
                        widget.markerColor =
                            MARKINGBACKCOLOR[selectedColorIndex];
                        ref.watch(markerColorProvider.notifier).state =
                            widget.markerColor;
                        widget.mapController?.addOverlay(
                          NMarker(
                            iconTintColor: widget.markerColor,
                            id: widget.testMarker,
                            position: NLatLng(
                                widget.markerLatitude, widget.markerLongitude),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const Spacer(),
              if (widget.recordTap)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.markerTap ? POST_BUTTON : MARKER_BUTTON,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    List<String> imageUrls = [];
                    for (var image in selectedImages) {
                      File imageFile = File(image.path);
                      final taskSnapshot = await FirebaseStorage.instance
                          .ref('images/${Path.basename(imageFile.path)}')
                          .putFile(imageFile);
                      final imageUrl = await taskSnapshot.ref.getDownloadURL();
                      imageUrls.add(imageUrl);
                    }
                    setState(() {
                      if (widget.markerTap) {
                        String markerId = uuid.v4().toString();
                        String title = titleController.text;
                        if (formKey.currentState?.validate() ?? false) {
                          RecordModel recordModel = RecordModel(
                            selectedColor: widget.markerColor.value,
                            title: title,
                            content: contentController.text,
                            selected: selectedPicGroup.toString(),
                            dataTime: DateTime.now(),
                            markerLatitude: widget.markerLatitude,
                            markerLongitude: widget.markerLongitude,
                            imgUrl: imageUrls,
                            markerId: markerId,
                          );
                          if (widget.recordTap) {
                            postProvider.savePostToFirestore(recordModel);
                          }
                          removeController();
                          widget.mapController!.deleteOverlay(
                            NOverlayInfo(
                              type: NOverlayType.marker,
                              id: widget.testMarker,
                            ),
                          );
                          widget.tapMarker = NMarker(
                            iconTintColor: widget.markerColor,
                            id: markerId,
                            position: NLatLng(
                              widget.markerLatitude,
                              widget.markerLongitude,
                            ),
                          );
                          widget.mapController!.addOverlay(widget.tapMarker);
                          final onMarkerInfoWindow = NInfoWindow.onMarker(
                            id: markerId,
                            text: title,
                          );
                          widget.tapMarker.openInfoWindow(onMarkerInfoWindow);
                          widget.onTapMarkerChanged(NMarker(
                            iconTintColor: widget.markerColor,
                            id: markerId,
                            position: NLatLng(
                                widget.markerLatitude, widget.markerLongitude),
                          ));
                        }
                      }
                    });
                    widget.onMarkerTapChanged(widget.markerTap);
                    widget.onRecordTapChanged(widget.recordTap);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      '마커 추가하기',
                      style: TextStyle(color: RECORD_TEXT, fontSize: 17),
                    ),
                  ),
                ),
            ],
          ),
          if (widget.markerTap && !widget.recordTap)
            const Text(
              '지도에 원하는 장소를 눌러주세요',
              style: TextStyle(color: PHOTO_BUTTON),
            ),
          if (widget.recordTap)
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                textFormField(
                  key: const ValueKey(1),
                  focusNode: titleFocus,
                  controller: titleController,
                  maxLength: 15,
                  borderRadius: 30,
                  errorBorderRadius: 30,
                  counterStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: RECORD_OUTLINE,
                      ),
                  hintText: '제목',
                  keyboardType: TextInputType.text,
                  validator: (val) => CheckValidate().validatelength(
                    focusNode: titleFocus,
                    value: val.toString(),
                    title: '제목',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                textFormField(
                  key: const ValueKey(2),
                  focusNode: contentFocus,
                  controller: contentController,
                  borderRadius: 10,
                  errorBorderRadius: 10,
                  hintText: '내용을 입력하세요',
                  maxLines: 8,
                  keyboardType: TextInputType.text,
                  validator: (val) => CheckValidate().validatelength(
                    focusNode: contentFocus,
                    value: val.toString(),
                    title: '내용',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (selectedImages.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      itemCount: selectedImages.length + 1,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index == selectedImages.length) {
                          return dottedBorder(
                            width: 100,
                          );
                        }

                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ImageLayout(
                                        initialIndex: index,
                                        selectedImages: selectedImages,
                                        networkImages: false,
                                      );
                                    });
                              },
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.file(
                                  File(selectedImages[index].path),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImages.removeAt(index);
                                  });
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outlined,
                                  size: 30,
                                  color: WHITE_COLOR,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                if (selectedImages.isEmpty)
                  dottedBorder(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                  )
              ],
            ),
        ],
      ),
    );
  }

  void removeController() {
    selectedImages = [];
    titleController.clear();
    contentController.clear();
    selectedPicGroup = null;
    widget.markerTap = false;
    widget.recordTap = false;
  }

  final picker = ImagePicker();
  Future getImages() async {
    final pickedFile = await picker.pickMultiImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    setState(() {
      List<XFile> xfilePick = pickedFile;

      if (xfilePick.isNotEmpty) {
        for (var i = 0; i < xfilePick.length; i++) {
          selectedImages.add(xfilePick[i]);
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
      }
    });
  }

  DottedBorder dottedBorder({
    double? height,
    double? width,
  }) {
    return DottedBorder(
      color: RECORD_OUTLINE,
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(
            12,
          ),
        ),
        child: Center(
          child: SizedBox(
            height: height,
            width: width,
            child: IconButton(
              onPressed: () {
                getImages();
              },
              icon: const Icon(
                Icons.photo_library_outlined,
                color: PHOTO_BUTTON,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
