import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../common/const/color.dart';
import '../../record/model/record_model.dart';
import '../../record/provider/record_detail_provider.dart';

class PostListScreen extends ConsumerStatefulWidget {
  const PostListScreen({super.key});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  final PagingController<DocumentSnapshot?, RecordModel> pagingController =
      PagingController(firstPageKey: null);
  static const pageSize = 8;
  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagedListView(
        pagingController: pagingController,
        builderDelegate:
            PagedChildBuilderDelegate(itemBuilder: (context, data, index) {
          final recordData = pagingController.itemList![index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {});
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
    );
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
