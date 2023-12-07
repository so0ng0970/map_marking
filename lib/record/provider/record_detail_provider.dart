import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/record_model.dart';

final markerColorProvider = StateProvider<Color>((ref) => Colors.black);

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
      model.recordId = docRef.id;
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
  Stream<List<RecordModel>> getDiaryListFromFirestore(DateTime selectedDay) {
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
}
