import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/record_model.dart';

final recordDetailProvider =
    StateNotifierProvider<RecordDetailProvider, PostState>(
        (ref) => RecordDetailProvider());
final selectedDateStateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

class PostState {
  final bool isLoading;
  final String? error;
  final RecordModel? post;

  PostState({
    this.isLoading = false,
    this.error,
    this.post,
  });
}

User? currentUser = FirebaseAuth.instance.currentUser;

class RecordDetailProvider extends StateNotifier<PostState> {
  RecordDetailProvider() : super(PostState());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 글 저장
  Future<void> savePostToFirestore(RecordModel model) async {
    state = PostState(isLoading: true);

    try {
      DocumentReference docRef = _firestore
          .collection('user')
          .doc(currentUser?.uid)
          .collection('post')
          .doc();

      await docRef.set(model.toJson());

      state = PostState(post: model);
    } catch (e) {
      state = PostState(error: e.toString());
    }
  }
}
