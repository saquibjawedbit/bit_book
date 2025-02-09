import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceModel {
  final String subject;
  final double? requiredPercentage;
  final String? uid;
  int presentClasses;
  int absentClasses;
  int leaveClasses;

  AttendanceModel({
    required this.subject,
    this.requiredPercentage = 75.0,
    this.uid,
    this.presentClasses = 0,
    this.absentClasses = 0,
    this.leaveClasses = 0,
  });

  int get totalClasses => presentClasses + absentClasses + leaveClasses;

  double get attendancePercentage {
    if (totalClasses == 0) return 0;
    return (presentClasses / totalClasses) * 100;
  }

  bool get isPassing {
    if (requiredPercentage == null) return true;
    return attendancePercentage >= requiredPercentage!;
  }

  int classesNeededToPass() {
    if (requiredPercentage == null || isPassing) return 0;

    double required = requiredPercentage! / 100;
    int classesNeeded =
        ((required * totalClasses - presentClasses) / (1 - required)).ceil();
    return classesNeeded;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'subject': subject,
      'requiredPercentage': requiredPercentage,
      'presentClasses': presentClasses,
      'absentClasses': absentClasses,
      'leaveClasses': leaveClasses,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'subject': subject,
      'requiredPercentage': requiredPercentage,
      'presentClasses': presentClasses,
      'absentClasses': absentClasses,
      'leaveClasses': leaveClasses,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'updatedAt': FieldValue.serverTimestamp().toString(),
    };
  }

  Future<void> saveToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final data = {
        'subject': subject,
        'requiredPercentage': requiredPercentage,
        'presentClasses': presentClasses,
        'absentClasses': absentClasses,
        'leaveClasses': leaveClasses,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (uid != null) {
        // Document exists, update it
        await firestore.collection('attendance').doc(uid).set(
              data,
              SetOptions(merge: true),
            );
      } else {
        // Create new document
        final docRef = await firestore.collection('attendance').add(data);
        // Update the uid field after creation
        await docRef.update({'uid': docRef.id});
      }
    } catch (e) {
      debugPrint('Error saving attendance: $e');
    }
  }

  static Future<List<AttendanceModel>> loadAllFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceModel.fromMap({...doc.data(), 'uid': doc.id}))
        .toList();
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      subject: map['subject'],
      requiredPercentage: map['requiredPercentage'],
      presentClasses: map['presentClasses'],
      absentClasses: map['absentClasses'],
      leaveClasses: map['leaveClasses'],
      uid: map['uid'],
    );
  }
}
