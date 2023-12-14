import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/record_model.dart';

final markerColorProvider = StateProvider<Color>((ref) => Colors.black);
final recordDetailProvider =
    StateNotifierProvider<RecordDetailProvider, PostState>(
        (ref) => RecordDetailProvider());

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

      model.postId = docRef.id;
      await docRef.set(model.toJson());

      state = PostState(post: model);
    } catch (e) {
      state = PostState(error: e.toString());
    }
  }

  // 글 스크롤 - get
  Future<List<DocumentSnapshot>> getPostListScrollFromFirestore(
      DocumentSnapshot? pageKey, int pageSize) async {
    Query firebase = FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser?.uid)
        .collection('post')
        .orderBy(
          'dataTime',
          descending: true,
        )
        .limit(pageSize);

    if (pageKey != null) {
      firebase = firebase.startAfterDocument(pageKey);
    }
    final snapshot = await firebase.get();
    return snapshot.docs;
  }

  // 글 불러오기 - get
  Stream<List<RecordModel>> getPostListFromFirestore() {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser?.uid)
        .collection('post')
        .orderBy(
          'dataTime',
          descending: true,
        )
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecordModel.fromJson(doc.data()))
            .toList());
  }

  // 글 삭제
  Future<void> deletePost(String postId) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(currentUser?.uid)
        .collection('post')
        .doc(postId)
        .delete();
  }

  // 글 수정
  Future<void> updatePostInFirestore({
    required String postId,
    List<String>? imgUrl,
    required String content,
    required String title,
    required String selected,
    required String diaryId,
  }) async {
    try {
      await _firestore
          .collection('user')
          .doc(currentUser?.uid)
          .collection('post')
          .doc(postId)
          .update({
        'selected': selected,
        'imgUrl': imgUrl,
        'content': content,
        'title': title,
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
