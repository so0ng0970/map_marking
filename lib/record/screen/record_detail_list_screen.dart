// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:map_marking/common/const/color.dart';
import 'package:map_marking/record/screen/record_detail_screen.dart';

import '../model/record_model.dart';
import '../provider/record_detail_provider.dart';

class RecordDetailListScreen extends ConsumerStatefulWidget {
  bool markerTap;
 NaverMapController? mapController;
  final Function(bool) onMarkerTapChanged;
  RecordDetailListScreen({
    Key? key,
    required this.markerTap,
    this.mapController,
    required this.onMarkerTapChanged,
  }) : super(key: key);

  @override
  ConsumerState<RecordDetailListScreen> createState() =>
      _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailListScreen> {
  static const pageSize = 8;
  final PagingController<DocumentSnapshot?, RecordModel> pagingController =
      PagingController(firstPageKey: null);
  bool detailTap = false;
  String? markerId;
  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.drag_handle,
          color: LOCATION,
        ),
        if (!detailTap)
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
        if (!detailTap)
          const SizedBox(
            height: 10,
          ),
        SingleChildScrollView(
          child: SizedBox(
            height: 445,
            child: detailTap
                ? RecordDetailScreen(
                  mapController:widget.mapController ,
                    markerId: markerId.toString(),
                    detailTap: detailTap,
                    onDetailTapChanged: onDetailTapChanged,
                  )
                : PagedListView(
                    pagingController: pagingController,
                    builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, data, index) {
                      final recordData = pagingController.itemList![index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              detailTap = true;
                              markerId = recordData.markerId.toString();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: DETAIL_BORDER,
                                width: 2,
                              ),
                              color: DETAIL_BG,
                            ),
                            height: 150,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/icon/character1.png',
                                  scale: 4,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recordData.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: 250,
                                      child: Text(
                                        recordData.content,
                                        style: const TextStyle(
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
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        )
      ],
    );
  }

  void onDetailTapChanged(bool detailTap) {
    setState(() {
      this.detailTap = detailTap;
    });
  }

  Future<void> fetchPage(DocumentSnapshot? pageKey) async {
    try {
      print('Fetching new page...');
      final newSnapshots = await ref
          .watch(recordDetailProvider.notifier)
          .getPostListScrollFromFirestore(
            pageKey,
            pageSize,
          );

      if (newSnapshots.isEmpty) {
        pagingController.appendLastPage([]);
        return;
      }
      final newItems = newSnapshots
          .map((snapshot) =>
              RecordModel.fromJson(snapshot.data() as Map<String, dynamic>))
          .toList();

      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
        print('Fetched last page with ${newItems.length} items.');
      } else {
        final nextPageKey = newSnapshots.last;
        pagingController.appendPage(newItems, nextPageKey);
        print('Fetched new page with ${newItems.length} items.');
      }
    } catch (error) {
      print('Error fetching page: $error');
      pagingController.error = error;
    }
  }
}
