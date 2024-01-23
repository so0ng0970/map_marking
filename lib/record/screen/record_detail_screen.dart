// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:map_marking/common/const/color.dart';
import 'package:map_marking/record/layout/button_layout.dart';
import 'package:map_marking/record/layout/image_layout.dart';
import 'package:map_marking/record/provider/record_detail_provider.dart';
import 'package:map_marking/record/screen/record_screen.dart';

import '../model/record_model.dart';
import '../utils/data_util.dart';

class RecordDetailScreen extends ConsumerStatefulWidget {
  PagingController<DocumentSnapshot?, RecordModel>? pagingController;
  final NaverMapController? mapController;

  String markerId;
  bool detailTap;
  bool markerTap;
  bool recordTap;
  final Function(String) removeMarker;
  final Function(bool) onDetailTapChanged;
  final Function(bool) onMarkerTapChanged;
  final Function(bool) onRecordTapChanged;
  final Function(NMarker marker) onMarkerCreated;
  String testMarker;

  RecordDetailScreen({
    super.key,
    this.pagingController,
    required this.mapController,
    required this.markerId,
    required this.detailTap,
    required this.markerTap,
    required this.recordTap,
    required this.removeMarker,
    required this.onDetailTapChanged,
    required this.onMarkerTapChanged,
    required this.onRecordTapChanged,
    required this.onMarkerCreated,
    required this.testMarker,
  });

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  bool edit = false;
  String? postId;
  @override
  Widget build(BuildContext context) {
    final detailProvider = ref.watch(recordDetailProvider.notifier);

    return SizedBox(
      height: 450,
      child: StreamBuilder(
        stream: detailProvider.getPostListFromFirestore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            List<RecordModel> posts = snapshot.data!;
            RecordModel post = posts.firstWhere(
              (post) => post.markerId == widget.markerId,
            );
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: DETAIL_BORDER,
                    width: 2,
                  ),
                  color: DETAIL_BG,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(fontSize: 30),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.detailTap = false;
                                widget.onDetailTapChanged(widget.detailTap);
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: LOCATION,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            child: Text(DataUtils.getTimeFromDateTime(
                              dateTime: post.dataTime,
                            )),
                          ),
                          const Spacer(),
                          EditeDeleteButton(
                            DeleteButton: () async {
                              setState(() {
                                detailProvider.deletePost(
                                  post.postId.toString(),
                                );
                                widget.removeMarker(widget.markerId.toString());

                                widget.detailTap = false;
                                widget.onDetailTapChanged(widget.detailTap);
                                widget.pagingController?.refresh();
                                context.pop();
                              });
                            },
                            editButton: () {
                              setState(() {
                                postId = post.postId;
                                widget.recordTap = true;
                                widget.onRecordTapChanged(widget.recordTap);
                                edit = true;
                                showBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        color: EDIT_BG,
                                        height: 550,
                                        child: RecordScreen(
                                          pagingController:
                                              widget.pagingController,
                                          postId: postId,
                                          markerTap: true,
                                          recordTap: true,
                                          onMarkerTapChanged:
                                              widget.onMarkerTapChanged,
                                          onRecordTapChanged:
                                              widget.onRecordTapChanged,
                                          onMarkerCreated:
                                              widget.onMarkerCreated,
                                          mapController: widget.mapController,
                                          testMarker: widget.testMarker,
                                          edit: edit,
                                        ),
                                      );
                                    });
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(color: DETAIL_BORDER),
                      if (post.imgUrl!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 200,
                              child: PageView.builder(
                                itemCount: post.imgUrl!.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ImageLayout(
                                              networkImages: true,
                                              selectedNetworkImages:
                                                  post.imgUrl,
                                              initialIndex: index);
                                        },
                                      );
                                    },
                                    child: Image.network(
                                      post.imgUrl![index],
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Text('d');
        },
      ),
    );
  }

  void onEditTapChanged(bool edit) {
    setState(() {
      this.edit = edit;
    });
  }
}

class EditeDeleteButton extends StatelessWidget {
  VoidCallback editButton;
  VoidCallback DeleteButton;
  EditeDeleteButton({
    Key? key,
    required this.editButton,
    required this.DeleteButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: editButton,
          child: const Icon(
            Icons.mode_edit_outline,
            size: 20,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ButtonLayout(
                  onPressed: DeleteButton,
                  text: '정말 삭제하시겠습니까?',
                );
              },
            );
          },
          child: const Icon(
            Icons.delete_forever_outlined,
            size: 20,
            color: DROP_TEXT_1,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }
}
