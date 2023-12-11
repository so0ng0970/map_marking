// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:map_marking/common/const/color.dart';
import 'package:map_marking/record/layout/button_layout.dart';
import 'package:map_marking/record/layout/image_layout.dart';
import 'package:map_marking/record/provider/record_detail_provider.dart';

import '../model/record_model.dart';

class RecordDetailScreen extends ConsumerStatefulWidget {
  NaverMapController? mapController;
  String markerId;
  bool detailTap;
  final Function(bool) onDetailTapChanged;
  RecordDetailScreen({
    super.key,
    this.mapController,
    required this.markerId,
    required this.detailTap,
    required this.onDetailTapChanged,
  });

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final detailProvider = ref.watch(recordDetailProvider.notifier);

    return StreamBuilder(
      stream: detailProvider.getPostListFromFirestore(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          List<RecordModel> posts = snapshot.data!;
          RecordModel? post = posts.firstWhere(
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
                    EditeDeleteButton(
                      DeleteButton: () {
                        detailProvider.deletePost(
                          post.postId.toString(),
                        );
                        widget.mapController!.deleteOverlay(
                          NOverlayInfo(
                            type: NOverlayType.marker,
                            id: post.markerId,
                          ),
                        );
                        widget.detailTap = false;
                        widget.onDetailTapChanged(widget.detailTap);
                        context.pop();
                      },
                      editButton: () {},
                    ),
                    const Divider(color: DETAIL_BORDER),
                    if (post.imgUrl!.isNotEmpty)
                      Column(
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
                                            selectedNetworkImages: post.imgUrl,
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
                          )
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
    );
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
