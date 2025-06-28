// services/member_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/utils/constants.dart';

import '../models/user_modal/member_model.dart';

class MemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createMember(Member member) async {
    await _firestore.collection('members').doc(member.uid).set(member.toMap());
  }

  Future<List<Member>> getMembers(String createdBy) async {
    print(createdBy);
    final querySnapshot = await _firestore
        .collection('members')
        .where('createdBy', isEqualTo: createdBy)
        .get();
    return querySnapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();
  }

  Future<void> updateMember(Member member) async {
    await _firestore.collection('members').doc(member.uid).update(member.toMap());
  }

  Future<void> deleteMember(String uid) async {
    await _firestore.collection('members').doc(uid).delete();
  }
}